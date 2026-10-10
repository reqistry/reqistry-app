#!/bin/sh
# Launch a remote iOS simulator running this working tree (Codemagic provider).
# Usage: sh scripts/mobai-sim-start.sh [--duration 30m] [--no-wait]
# Verified against https://mobai.run/docs/cloud-agents/ (mobai-dev 1.3.4).
# Needs: MobAI sign-in (mobai-dev login), CODEMAGIC_API_TOKEN exported,
# builder.json + codemagic.yaml + .builder/ci/runner.sh committed to main,
# MOBAI_API_KEY in the Codemagic app's `builder` env group.
set -eu
export PATH="$HOME/.mobai/bin:$PATH"
~/.mobai/bin/mobai-up
mobai-dev sim start --provider codemagic "$@"
