#!/usr/bin/env bash
# List available scripts.

# Note that printf isn't POSIX and doesn't work on macOS.
# -printf "%p\n"

find "$KOOPA_BIN_DIR" -maxdepth 1 -type f -not -name ".*" -not -name "koopa" | sort
