#!/usr/bin/env bash
# Checks the token spacing of GDScript files against gdformat.
# Only lines where gdformat changes the whitespace between tokens are reported,
# line wrapping, blank lines, quotes and indentation are not checked.
#
# Usage: gdformat-check.sh [--line-length <n>] [--exclude <find -path pattern>]... <path>...
set -euo pipefail

line_length=180
excludes=()
paths=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --line-length) line_length="$2"; shift 2 ;;
    --exclude) excludes+=(-not -path "$2"); shift 2 ;;
    *) paths+=("$1"); shift ;;
  esac
done

mapfile -t files < <(find "${paths[@]}" -name '*.gd' "${excludes[@]}" | sort)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp --parents "${files[@]}" "$work"

if ! gdformat --line-length="$line_length" "$work" > /dev/null 2>&1; then
  for file in "${files[@]}"; do
    if ! gdformat --line-length="$line_length" "$work/$file" > /dev/null 2>&1; then
      echo "::warning file=$file::gdformat can't format this file, token spacing not checked"
      cp "$file" "$work/$file"
    fi
  done
fi

# gdformat writes method chains as `. method()`, the project keeps `.method()`
find "$work" -name '*.gd' -exec sed -i -E 's/^([[:space:]]*)\. /\1./' {} +

for file in "${files[@]}"; do
  diff --strip-trailing-cr -U0 --label "$file" --label "$file" "$file" "$work/$file" || true
done | awk -v checked="${#files[@]}" '
  function indentation(line) { match(line, /^[ \t]*/); return substr(line, 1, RLENGTH) }
  function trimmed(line) { sub(/^[ \t]+/, "", line); return line }
  function tokens(line) { gsub(/[[:space:]]/, "", line); return line }
  function report_hunk(   i, j, next_new, given, expected) {
    next_new = 1
    for (i = 1; i <= removed; i++) {
      given = old_lines[i]
      if (tokens(given) == "") continue
      for (j = next_new; j <= added; j++) {
        if (tokens(given) != tokens(new_lines[j])) continue
        expected = new_lines[j]
        next_new = j + 1
        if (given != expected && indentation(given) == indentation(expected)) {
          printf "%s:%d: wrong token spacing\n    found:    %s\n    expected: %s\n", file, start + i - 1, trimmed(given), trimmed(expected)
          findings++
        }
        break
      }
    }
    removed = 0; added = 0
  }
  /^--- / { report_hunk(); next }
  /^\+\+\+ / { file = substr($0, 5); next }
  /^@@ / { report_hunk(); split(substr($2, 2), range, ","); start = range[1]; next }
  /^-/ { old_lines[++removed] = substr($0, 2); next }
  /^\+/ { new_lines[++added] = substr($0, 2); next }
  END {
    report_hunk()
    printf "Checked %d files, %d lines with wrong token spacing.\n", checked, findings
    exit findings > 0
  }
'
