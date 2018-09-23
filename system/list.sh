#!/usr/bin/env bash

# List available binaries.
# 2018-09-22

find "$KOOPA_BINDIR" \
    -maxdepth 1 -type f \
    -not -name ".*" -not -name "koopa" \
    -print0 | \
    xargs -0 basename | sort
