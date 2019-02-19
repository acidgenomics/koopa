#!/bin/sh

# Check python (any version).
# Consider requiring >= 3 in a future update.

command -v python >/dev/null 2>&1 || {
    echo >&2 "koopa requires python."
    exit 1
}
