#!/usr/bin/env bash

# seqcloud bash shell boatloader
# (c) 2018 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

if [[ -z "$INTERACTIVE" ]]; then
    . "$SEQCLOUD_DIR"/load/load.sh
fi
