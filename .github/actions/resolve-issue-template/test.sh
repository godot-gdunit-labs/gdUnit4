#!/usr/bin/env bash
# Exercises resolve.sh directly against fixture issue payloads, mocking `gh` so it never hits the
# network. Run from anywhere: bash .github/actions/resolve-issue-template/test.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

export GITHUB_REPOSITORY='MikeSchulze/gdUnit4'

pass=0
fail=0

run_case() {
  local desc="$1" fixture="$2" expected_number="$3" expected_state="$4" expected_name="$5" expected_ids="$6"

  gh() { printf '%s' "$GH_FIXTURE"; }
  export -f gh
  export GH_FIXTURE="$fixture"

  rm -rf triage
  GITHUB_OUTPUT=$(mktemp)
  export GITHUB_OUTPUT
  ISSUE_NUMBER="$expected_number" bash .github/actions/resolve-issue-template/resolve.sh

  local actual_number actual_state actual_name actual_ids
  actual_number=$(grep '^number=' "$GITHUB_OUTPUT" | cut -d= -f2-)
  actual_state=$(grep '^state=' "$GITHUB_OUTPUT" | cut -d= -f2-)
  actual_name=$(grep '^template-name=' "$GITHUB_OUTPUT" | cut -d= -f2-)
  actual_ids=$(grep '^required-ids=' "$GITHUB_OUTPUT" | cut -d= -f2-)

  if [ "$actual_number" = "$expected_number" ] && [ "$actual_state" = "$expected_state" ] \
    && [ "$actual_name" = "$expected_name" ] && [ "$actual_ids" = "$expected_ids" ]; then
    echo "PASS: $desc"
    pass=$((pass + 1))
  else
    echo "FAIL: $desc"
    echo "  expected number=$expected_number state=$expected_state template-name=$expected_name required-ids=$expected_ids"
    echo "  actual   number=$actual_number state=$actual_state template-name=$actual_name required-ids=$actual_ids"
    fail=$((fail + 1))
  fi

  rm -f "$GITHUB_OUTPUT"
  rm -rf triage
}

run_case "bug report" \
  '{"number":1,"state":"open","type":{"name":"Bug"},"labels":[{"name":"API"}]}' \
  1 open 'Bug Report' \
  '["gdunit-version","godot-version","system","bug-description","steps-to-reproduce"]'

run_case "feature request" \
  '{"number":2,"state":"open","type":{"name":"Feature"},"labels":[{"name":"API"}]}' \
  2 open 'Feature Request' \
  '["feature-type","problem-description","proposed-solution"]'

run_case "documentation" \
  '{"number":3,"state":"open","type":{"name":"Documentation"},"labels":[{"name":"documentation"}]}' \
  3 open 'Documentation' \
  '["doc-type","description","use-case","doc-link"]'

run_case "task" \
  '{"number":4,"state":"open","type":{"name":"Task"},"labels":[{"name":"API"}]}' \
  4 open 'Task' \
  '["task-category","task-description","acceptance-criteria"]'

run_case "improvement" \
  '{"number":5,"state":"open","type":{"name":"Improvement"},"labels":[{"name":"improvement"}]}' \
  5 open 'Improvement' \
  '["refactoring-type","current-state","problems-motivation","proposed-changes","affected-areas","backward-compatibility"]'

run_case "unrecognized type" \
  '{"number":6,"state":"open","type":null,"labels":[]}' \
  6 open '' '[]'

run_case "closed issue state" \
  '{"number":7,"state":"closed","type":{"name":"Bug"},"labels":[{"name":"API"}]}' \
  7 closed 'Bug Report' \
  '["gdunit-version","godot-version","system","bug-description","steps-to-reproduce"]'

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
