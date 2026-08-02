#!/usr/bin/env bash
set -euo pipefail

mkdir -p triage
gh api "repos/$GITHUB_REPOSITORY/issues/$ISSUE_NUMBER" > triage/issue.json

echo "number=$(jq -r '.number' triage/issue.json)" >> "$GITHUB_OUTPUT"
echo "state=$(jq -r '.state // "open"' triage/issue.json)" >> "$GITHUB_OUTPUT"

type_name=$(jq -r '.type.name // empty' triage/issue.json | tr '[:upper:]' '[:lower:]')

# Each template declares its own unique `type:`, so the first match is the only match.
template_path=''
for candidate in .github/ISSUE_TEMPLATE/*.yml; do
  if [ "$(basename "$candidate")" = 'config.yml' ]; then
    continue
  fi
  candidate_type=$(yq -r '.type // ""' "$candidate" | tr '[:upper:]' '[:lower:]')
  if [ "$candidate_type" = "$type_name" ]; then
    template_path="$candidate"
    break
  fi
done

if [ -z "$template_path" ]; then
  echo "template-name=" >> "$GITHUB_OUTPUT"
  echo "required-ids=[]" >> "$GITHUB_OUTPUT"
  exit 0
fi

template_name=$(yq -r '.name' "$template_path")
required_ids=$(yq -o=json '.' "$template_path" \
  | jq -c '[.body[] | select(.type != "markdown") | select(.validations.required == true) | .id]')

echo "template-name=$template_name" >> "$GITHUB_OUTPUT"
echo "required-ids=$required_ids" >> "$GITHUB_OUTPUT"
