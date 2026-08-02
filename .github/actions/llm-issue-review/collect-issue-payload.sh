#!/usr/bin/env bash
set -euo pipefail

mkdir -p triage
gh api "repos/$GITHUB_REPOSITORY/issues/$ISSUE_NUMBER" > triage/issue.json
jq -r '.body // ""' triage/issue.json > triage/body.md
jq -r '.title // ""' triage/issue.json > triage/title.txt
