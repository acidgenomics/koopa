#!/bin/sh

git --version | \
    head -n 1 | \
    cut -d ' ' -f 3
