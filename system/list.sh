#!/usr/bin/env bash

# List available scripts.
# 2018-09-23

find "$KOOPA_BINDIR" \
    -maxdepth 1 -type f \
    -not -name ".*" -not -name "koopa"
    
    # -print0 | \
    # xargs -0 basename | sort
