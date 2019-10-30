#!/bin/sh

clang --version \
    | head -n 1 \
    | cut -d ' ' -f 4
