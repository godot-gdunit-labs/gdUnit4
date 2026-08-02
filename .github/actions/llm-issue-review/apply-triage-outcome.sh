#!/usr/bin/env bash
set -euo pipefail

{
  echo "## Issue triage for #$NUMBER"
  echo
  if [ "$DRY_RUN" = 'true' ]; then
    echo 'Mode: **DRY RUN, nothing was written**'
  else
    echo 'Mode: **applied**'
  fi
  echo
  echo "Decision: $REASON"
  echo
  echo "- label added: ${ADD_LABEL:-none}"
  echo "- label removed: ${REMOVE_LABEL:-none}"
  echo "- issue closed: $CLOSE"
  if [ -f triage/comment.md ]; then
    echo
    echo '<details><summary>Triage comment</summary>'
    echo
    cat triage/comment.md
    echo
    echo '</details>'
  fi
} >> "$GITHUB_STEP_SUMMARY"

if [ "$DRY_RUN" = 'true' ]; then
  exit 0
fi

if [ -n "$REMOVE_LABEL" ]; then
  gh issue edit "$NUMBER" --repo "$GITHUB_REPOSITORY" --remove-label "$REMOVE_LABEL"
fi
if [ -n "$ADD_LABEL" ]; then
  gh issue edit "$NUMBER" --repo "$GITHUB_REPOSITORY" --add-label "$ADD_LABEL"
fi

# A clean pass never posts a comment, only the failing path leaves triage/comment.md behind.
# One sticky comment per issue, updated in place, so repeated runs never flood the thread.
if [ -f triage/comment.md ]; then
  comment_id=$(gh api --paginate "repos/$GITHUB_REPOSITORY/issues/$NUMBER/comments" \
    --jq "[.[] | select(.body | contains(\"$MARKER\")) | .id] | first // empty")
  jq -n --rawfile body triage/comment.md '{body: $body}' > triage/comment.json
  if [ -z "$comment_id" ]; then
    gh api --method POST "repos/$GITHUB_REPOSITORY/issues/$NUMBER/comments" --input triage/comment.json
  else
    gh api --method PATCH "repos/$GITHUB_REPOSITORY/issues/comments/$comment_id" --input triage/comment.json
  fi
fi

if [ "$CLOSE" = 'true' ]; then
  gh issue close "$NUMBER" --repo "$GITHUB_REPOSITORY" --reason 'not planned'
fi
