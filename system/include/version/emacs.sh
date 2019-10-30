#!/bin/sh

emacs --version \
    | head -n 1 \
    | cut -d ' ' -f 3
