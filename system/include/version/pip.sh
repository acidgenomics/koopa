#!/bin/sh

pip3 --version \
    | head -n 1 \
    | cut -d ' ' -f 2
