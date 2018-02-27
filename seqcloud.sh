#!/usr/bin/env bash

# seqcloud bootloader
# (c) 2018 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

export SEQCLOUD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    return 1
fi

# Login scripts
for file in $(find "$SEQCLOUD_DIR"/login \
    -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset -v file
