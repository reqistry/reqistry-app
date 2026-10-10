#!/bin/sh
# Stop the shared simulator session started from this project.
# Usage: sh scripts/mobai-sim-stop.sh
set -eu
export PATH="$HOME/.mobai/bin:$PATH"
mobai-dev sim stop
