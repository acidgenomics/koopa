#!/bin/sh

fzf --version \
    | head -n 1 \
    | cut -d ' ' -f 1
