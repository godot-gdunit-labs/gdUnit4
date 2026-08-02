#!/usr/bin/env bash
set -euo pipefail

if [ -z "${LLM_API_KEY:-}" ]; then
  echo "configured=false" >> "$GITHUB_OUTPUT"
  echo "LLM_API_KEY is not configured, substantiation and noise checks are skipped." >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

jq -n --rawfile prompt triage/prompt.md '{
  contents: [{role: "user", parts: [{text: $prompt}]}],
  generationConfig: {
    temperature: 0,
    responseMimeType: "application/json",
    responseSchema: {
      type: "OBJECT",
      properties: {
        verdict: {type: "STRING"},
        confidence: {type: "NUMBER"},
        unsupported_references: {type: "ARRAY", items: {type: "STRING"}},
        incomplete_required_ids: {type: "ARRAY", items: {type: "STRING"}},
        llm_signals: {
          type: "ARRAY",
          items: {
            type: "STRING",
            enum: [
              "draft_scaffolding_leak", "line_mismatch", "invented_artifacts", "misaligned_reasoning",
              "disproportionate_scope", "language_framework_confusion", "hallucinated_cli_flags",
              "over_specified_solution_offer", "over_commented_repro_code", "explaining_basics_to_maintainers",
              "llm_transition_phrases", "fabricated_methodology_claims", "excessive_structure"
            ]
          }
        },
        llm_signal_evidence: {
          type: "ARRAY",
          items: {
            type: "OBJECT",
            properties: {signal: {type: "STRING"}, detail: {type: "STRING"}},
            required: ["signal", "detail"]
          }
        }
      },
      required: [
        "verdict", "confidence", "unsupported_references", "incomplete_required_ids",
        "llm_signals", "llm_signal_evidence"
      ]
    }
  }
}' > triage/request.json

# A curl or jq failure here must never crash the job: it would abort before the
# decide/apply steps report anything at all, leaving this run's outcome completely
# unrecorded instead of a graceful "check unavailable this run".
#
# This calls the Gemini API specifically (endpoint, auth header, and request/response shape are
# all Gemini's contract). Swapping the model later means updating this call, LLM_MODEL alone won't
# do it.
if ! curl --silent --show-error --fail-with-body \
  --retry 3 --retry-delay 5 --max-time 120 \
  -X POST "https://generativelanguage.googleapis.com/v1beta/models/${LLM_MODEL}:generateContent" \
  -H 'content-type: application/json' \
  -H "x-goog-api-key: ${LLM_API_KEY}" \
  -d @triage/request.json -o triage/response.json; then
  echo "configured=false" >> "$GITHUB_OUTPUT"
  echo "LLM request failed, substantiation and noise checks are skipped for this run." >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

jq -r '.candidates[0].content.parts[0].text' triage/response.json > triage/review.json

# Every field the decide step reads must actually be present, not just "verdict": a
# degraded response can carry some fields while silently missing others.
if ! jq -e '
  has("verdict") and has("confidence") and has("unsupported_references")
  and has("incomplete_required_ids") and has("llm_signals") and has("llm_signal_evidence")
' triage/review.json > /dev/null 2>&1; then
  echo "configured=false" >> "$GITHUB_OUTPUT"
  echo "LLM response was incomplete, substantiation and noise checks are skipped for this run." >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

echo "configured=true" >> "$GITHUB_OUTPUT"
