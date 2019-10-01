#!/bin/sh

gcc --version 2>&1 | \
    sed -n '2p' | \
    cut -d ' ' -f 4
