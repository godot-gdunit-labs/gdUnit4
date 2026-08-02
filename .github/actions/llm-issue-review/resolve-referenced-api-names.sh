#!/usr/bin/env bash
set -euo pipefail

# Only GdUnit4 shaped identifiers are considered, so names from the reporter's own
# project can never trip the substantiation check.
grep -oE '\b(Gd[A-Z][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]*Assert[A-Za-z0-9_]*|assert_[a-z0-9_]+|verify_[a-z0-9_]+)\b' \
  triage/body.md | sort -u > triage/symbols.txt || true

: > triage/known.txt
: > triage/unknown.txt
while read -r name; do
  if [ -z "$name" ]; then
    continue
  fi
  # Declared in the repository, carried by a source file name (the *Impl classes
  # extend their interface without declaring class_name), documented, or declared by
  # the reporter's own snippet.
  if grep -rqE "(class_name|func|class)[[:space:]]+${name}\b" addons/gdUnit4 \
    || [ -n "$(find addons/gdUnit4 -type f \( -name "${name}.gd" -o -name "${name}.cs" \) -print -quit)" ] \
    || grep -rqw -- "$name" documentation \
    || grep -qE "(class_name|extends|func|class)[[:space:]]+${name}\b" triage/body.md; then
    echo "$name" >> triage/known.txt
  else
    echo "$name" >> triage/unknown.txt
  fi
done < triage/symbols.txt
