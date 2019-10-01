#!/bin/sh

tex --version | \
    head -n 1 | \
    cut -d '(' -f 2 | \
    cut -d ')' -f 1 | \
    cut -d ' ' -f 3 | \
    cut -d '/' -f 1
