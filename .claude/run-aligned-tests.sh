#!/usr/bin/env bash
# PostToolUse hook: run the aligned GdUnit4 test when a src/ file is edited.
# Mapping: addons/gdUnit4/src/X/Y.gd -> addons/gdUnit4/test/X/YTest.gd

data=$(cat)

# Use Python (always available) to extract file_path from JSON stdin
file_path=$(python -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    pass
" <<< "$data" 2>/dev/null)
[ -z "$file_path" ] && exit 0

# Normalize Windows backslashes
file_path="${file_path//\\//}"

# Only activate for source files under addons/gdUnit4/src/
[[ "$file_path" =~ addons/gdUnit4/src/(.+)\.gd$ ]] || exit 0

rel="${BASH_REMATCH[1]}"
test_rel="addons/gdUnit4/test/${rel}Test.gd"

# Skip if aligned test doesn't exist yet
[ -f "$test_rel" ] || exit 0

# Require GODOT_BIN
if [ -z "${GODOT_BIN:-}" ]; then
    python -c "import json; print(json.dumps({'systemMessage': '⚠ GODOT_BIN not set — skipping auto-test for $test_rel'}))"
    exit 0
fi

res_path="res://$test_rel"

if output=$(bash addons/gdUnit4/runtest.sh -a "$res_path" 2>&1); then
    python -c "import json; print(json.dumps({'systemMessage': '✅ Tests passed: $res_path'}))"
else
    python -c "
import json, sys
output = sys.argv[1][-3000:]
print(json.dumps({
    'systemMessage': '❌ Tests FAILED: $res_path',
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': 'Aligned tests FAILED for $res_path:\n' + output
    }
}))
" "$output"
fi
