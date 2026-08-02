#!/usr/bin/env bash
set -euo pipefail

add_label=''
remove_label=''
close='false'

unsubstantiated_hit='false'
llm_noise_hit='false'
incomplete_hit='false'
unsupported_count=0
incomplete_count=0
llm_signal_count=0
# Substantiation and noise verdicts only exist once the LLM check actually ran.
if [ "$REVIEW_CONFIGURED" = 'true' ]; then
  verdict=$(jq -r '.verdict' triage/review.json)
  confidence=$(jq -r '.confidence' triage/review.json)
  unsupported_count=$(jq -r '.unsupported_references | length' triage/review.json)
  incomplete_count=$(jq -r '.incomplete_required_ids | length' triage/review.json)
  llm_signal_count=$(jq -r '.llm_signals | length' triage/review.json)
  # Style, formatting, tone, and phrasing signals can be found in genuine reports too,
  # so on their own they never close an issue. At least one hard, fabrication-based signal
  # must fire alongside them.
  llm_hard_count=$(jq -r '
    [.llm_signals[] | select(
      . as $s
      | ([
          "explaining_basics_to_maintainers", "llm_transition_phrases",
          "fabricated_methodology_claims", "over_commented_repro_code",
          "excessive_structure"
        ] | index($s)) | not
    )] | length
  ' triage/review.json)
  confident=$(jq -rn --argjson a "$confidence" --argjson b "$MIN_CONFIDENCE" '$a >= $b')
  draft_leak_hit=$(jq -r '.llm_signals | index("draft_scaffolding_leak") != null' triage/review.json)

  # Plain stdout, not the step summary, so this is visible via `gh run view --log`.
  echo "raw LLM verdict: $(jq -c '.' triage/review.json)"
  echo "hard signal count: $llm_hard_count, total signal count: $llm_signal_count, confident: $confident"

  if [ "$verdict" = 'unsubstantiated' ] && [ "$confident" = 'true' ] && [ "$unsupported_count" -gt 0 ]; then
    unsubstantiated_hit='true'
  fi
  if [ "$confident" = 'true' ] && [ "$incomplete_count" -gt 0 ]; then
    incomplete_hit='true'
  fi
  # Two signals was too easy to trip on a genuine, detailed report, so require at least
  # three independent signals, at least one of them hard evidence, before treating a
  # report as fabricated noise. draft_scaffolding_leak is the one exception: no genuine
  # report can contain literal drafting or submission meta-commentary, so it closes on
  # its own once the model is confident it actually found that text.
  if [ "$llm_signal_count" -ge 3 ] && [ "$llm_hard_count" -ge 1 ]; then
    llm_noise_hit='true'
  elif [ "$draft_leak_hit" = 'true' ] && [ "$confident" = 'true' ]; then
    llm_noise_hit='true'
  fi
fi

if [ "$unsubstantiated_hit" = 'true' ] || [ "$llm_noise_hit" = 'true' ] || [ "$incomplete_hit" = 'true' ]; then
  reasons=()
  if [ "$unsubstantiated_hit" = 'true' ]; then
    reasons+=("$unsupported_count referenced API name(s) do not exist in this repository")
  fi
  if [ "$incomplete_hit" = 'true' ]; then
    reasons+=("$incomplete_count required template field(s) left unfilled")
  fi
  if [ "$llm_noise_hit" = 'true' ]; then
    reasons+=("$llm_signal_count fabricated content signal(s) detected")
  fi
  reason=$(printf '%s, ' "${reasons[@]}")
  reason=${reason%, }
  add_label="$UNVERIFIABLE_LABEL"
  remove_label="$PASSED_LABEL"
  if [ "$ISSUE_STATE" = 'open' ]; then
    close='true'
  fi
  {
    echo "$MARKER"
    echo
    echo '## This issue was closed by automated triage'
    echo
    if [ "$unsubstantiated_hit" = 'true' ]; then
      echo 'The reported behaviour could not be substantiated against this repository. The GdUnit4 API'
      echo 'names below appear in this report but are not defined or documented anywhere in the source'
      echo 'tree, which means the described behaviour cannot have been observed:'
      echo
      jq -r '.unsupported_references[] | "- `\(.)`"' triage/review.json
      echo
    fi
    if [ "$incomplete_hit" = 'true' ]; then
      echo 'This report used a template but left required section(s) unfilled:'
      echo
      jq -r '.incomplete_required_ids[] | "- `\(.)`"' triage/review.json
      echo
    fi
    if [ "$llm_noise_hit" = 'true' ]; then
      echo 'This report shows concrete signs of fabricated content:'
      echo
      jq -r '.llm_signal_evidence[] | "- **\(.signal)** — \(.detail)"' triage/review.json
      echo
    fi
    echo 'Reports like this are not accepted here, because they cost maintainer time without carrying'
    echo 'usable information.'
    echo
    echo 'This is not a judgement about how the report was written. A report written with the help of'
    echo 'any tool is welcome, as long as its content is real and reproducible.'
    echo
    echo 'If this was a genuine observation, please comment with the exact GdUnit4 and Godot versions,'
    echo 'the real code you ran and the real output you saw, and the issue will be reopened.'
  } > triage/comment.md
else
  reason='no action required'
  add_label="$PASSED_LABEL"
  remove_label="$UNVERIFIABLE_LABEL"
fi

{
  echo "add_label=$add_label"
  echo "remove_label=$remove_label"
  echo "close=$close"
  echo "reason=$reason"
} >> "$GITHUB_OUTPUT"
