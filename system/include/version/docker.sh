#!/bin/sh

docker --version       \
    | head -n 1        \
    | cut -d ' ' -f 3  \
    | cut -d ',' -f 1
