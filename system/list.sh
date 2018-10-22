#!/usr/bin/env bash

# List available scripts.
# 2018-09-23

find "$KOOPA_BIN_DIR" \
    -maxdepth 1 -type f \
    -not -name ".*" -not -name "koopa" \
    -printf "%f\n" | sort
