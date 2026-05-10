#!/usr/bin/env bash
printf '%s\n' \
    "Error: 'koopa header' is deprecated." \
    "Scripts using 'source \"\$(koopa header bash)\"' must be updated." \
    "Add 'set -Eeuo pipefail' to your script and source koopa" \
    "functions directly instead." \
    >&2
exit 1
