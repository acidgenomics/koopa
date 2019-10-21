#!/bin/sh

# Note that we're checking the TeX Live release year here.
# Here's what it looks like on Debian/Ubuntu:
# TeX 3.14159265 (TeX Live 2017/Debian)

tex --version          \
    | head -n 1        \
    | cut -d '(' -f 2  \
    | cut -d ')' -f 1  \
    | cut -d ' ' -f 3  \
    | cut -d '/' -f 1
