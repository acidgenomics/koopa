#!/usr/bin/env bash

major="$( \
    vim --version | \
    head -n 1 | \
    cut -d ' ' -f 5 \
)"

patch="$( \
    vim --version | \
    sed -n '2p' | \
    cut -d '-' -f 2 \
)"

printf "%s.%s\n" "$major" "$patch"
