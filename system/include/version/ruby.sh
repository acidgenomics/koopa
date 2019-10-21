#!/bin/sh

ruby --version         \
    | head -n 1        \
    | cut -d ' ' -f 2  \
    | cut -d 'p' -f 1
