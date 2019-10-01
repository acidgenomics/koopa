#!/bin/sh

shellcheck --version | \
    sed -n '2p' | \
    cut -d ' ' -f 2
