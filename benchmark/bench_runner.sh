#!/bin/bash
# GdUnit4 test-discovery benchmark.
#
# Measures the effect of the persistent discovery cache on a target Godot project by
# comparing a cold run (cache cleared) against warm runs (cache present). The difference
# is the discovery cost the cache removes; execution time is unaffected.
#
# It syncs this repo's addons/gdUnit4 into the target project before running, so the
# numbers reflect the addon revision currently checked out here.
#
# Usage:
#   benchmark/bench_runner.sh --godot <godot-bin> --project <path> [--iterations N] [--filter res://test/] [--no-sync]
#
# Example:
#   benchmark/bench_runner.sh \
#     --godot "/Applications/Godot 4.7.1.app/Contents/MacOS/Godot" \
#     --project ../my-project --iterations 5

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT=""
PROJECT=""
ITERATIONS=5
FILTER="res://test/"
DO_SYNC=1

while [ $# -gt 0 ]; do
	case "$1" in
		--godot) GODOT="$2"; shift 2 ;;
		--project) PROJECT="$2"; shift 2 ;;
		--iterations) ITERATIONS="$2"; shift 2 ;;
		--filter) FILTER="$2"; shift 2 ;;
		--no-sync) DO_SYNC=0; shift ;;
		*) echo "Unknown argument: $1" >&2; exit 2 ;;
	esac
done

[ -n "$GODOT" ] || { echo "--godot is required" >&2; exit 2; }
[ -n "$PROJECT" ] || { echo "--project is required" >&2; exit 2; }
[ -x "$GODOT" ] || { echo "Godot binary not executable: $GODOT" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"
[ -f "$PROJECT/project.godot" ] || { echo "No project.godot in $PROJECT" >&2; exit 2; }

if [ "$DO_SYNC" = "1" ]; then
	echo "Syncing addons/gdUnit4 -> $PROJECT ..."
	rsync -a --delete "$REPO_ROOT/addons/gdUnit4/" "$PROJECT/addons/gdUnit4/"
fi

CACHE_FILE="$PROJECT/.godot/gdunit_discover_cache.json"

# Warm the import cache once so import time is excluded from the timed runs.
echo "Warming import cache ..."
"$GODOT" --headless --import --path "$PROJECT" >/dev/null 2>&1 || true

run_once() { # -> prints elapsed milliseconds
	local start end
	start=$(python3 -c 'import time; print(time.time())')
	"$GODOT" --headless --path "$PROJECT" -s -d --remote-debug tcp://127.0.0.1:0 \
		res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "$FILTER" -c --ignoreHeadlessMode \
		>/dev/null 2>&1 || true
	end=$(python3 -c 'import time; print(time.time())')
	python3 -c "print(int(($end - $start) * 1000))"
}

median() { # median of stdin numbers
	sort -n | awk '{ a[NR]=$1 } END { if (NR%2) print a[(NR+1)/2]; else print int((a[NR/2]+a[NR/2+1])/2) }'
}

echo "Cold run (cache cleared) ..."
rm -f "$CACHE_FILE"
COLD=$(run_once)
echo "  cold: ${COLD} ms"

echo "Warm runs x$ITERATIONS ..."
WARM_VALUES=""
for i in $(seq 1 "$ITERATIONS"); do
	ms=$(run_once)
	echo "  warm $i/$ITERATIONS: ${ms} ms"
	WARM_VALUES="$WARM_VALUES$ms
"
done
WARM=$(printf '%s' "$WARM_VALUES" | median)

echo
echo "### GdUnit4 discovery-cache benchmark"
echo
echo "Project: \`$PROJECT\` | Godot: \`$("$GODOT" --version 2>/dev/null | head -1)\` | filter: \`$FILTER\`"
echo
echo "| Run | Wall clock |"
echo "| --- | ---: |"
echo "| Cold (cache cleared) | ${COLD} ms |"
echo "| Warm (median of $ITERATIONS) | ${WARM} ms |"
echo
echo "Cache saves ~$((COLD - WARM)) ms per warm run (discovery cost removed)."
