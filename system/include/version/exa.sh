#!/bin/sh

exa --version \
    | head -n 1 \
    | cut -d ' ' -f 2 \
    | sed 's/^v//'
