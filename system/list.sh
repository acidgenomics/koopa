#!/usr/bin/env bash

# List available scripts.

find "$KOOPA_BIN_DIR" \
    -maxdepth 1 -type f \
    -not -name ".*" -not -name "koopa" \
    -printf "%f\n" | sort
