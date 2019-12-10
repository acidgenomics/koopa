#!/bin/sh

sqlplus -v \
    | grep -E '^Version' \
    | head -n 1 \
    | cut -d ' ' -f 2
