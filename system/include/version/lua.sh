#!/bin/sh

lua -v | \
    head -n 1 | \
    cut -d ' ' -f 2
