#!/bin/sh

bcl2fastq --version 2>&1 \
    | sed -n '2p' \
    | cut -d ' ' -f 2 \
    | sed 's/^v//'
