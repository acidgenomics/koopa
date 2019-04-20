#!/usr/bin/env bash
set -Eeuxo pipefail

# Remove subdirectories.

find . -type d -name "$2" -print0 | xargs -0 -I {} rm -rf {}
