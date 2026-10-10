#!/bin/sh
# Smoke-drive the running simulator: launch app, settle, observe, screenshot.
# Usage: [MOBAI_DEVICE=<id>] sh scripts/mobai-sim-test.sh [./artifacts]
# Verified against https://mobai.run/docs/cli/ (mobai CLI).
set -eu
export PATH="$HOME/.mobai/bin:$PATH"
BUNDLE_ID="${BUNDLE_ID:-com.gwhyyy.publicApis}"
OUT="${1:-./artifacts}"

mobai devices list
mobai bridge start
mobai app launch "$BUNDLE_ID"
mobai wait --stable --timeout-ms 8000
mobai observe --include ui_tree
mobai screenshot --path "$OUT" --name launch --full
status=0
mobai assert exists "text-contains:Reqistry" || status=$?
mobai observe --include ui_tree
exit "$status"
