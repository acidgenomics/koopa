#!/bin/sh

gdalinfo --version \
    | head -n 1 \
    | cut -d ' ' -f 2 \
    | tr -d ','
