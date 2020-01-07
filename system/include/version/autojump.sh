#!/bin/sh

autojump --version 2>&1 \
    | head -n 1 \
    | cut -d ' ' -f 2 \
    | sed 's/^v//'
