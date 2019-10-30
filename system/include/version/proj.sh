#!/bin/sh

proj 2>&1 \
    | head -n 1 \
    | cut -d ' ' -f 2 \
    | tr -d ','
