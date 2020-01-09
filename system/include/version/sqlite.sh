#!/bin/sh

sqlite3 --version \
    | head -n 1 \
    | cut -d ' ' -f 1

