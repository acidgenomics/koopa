#!/usr/bin/env bash

# seqcloud HPC bootloader
# (c) 2018 Michael J. Steinbaugh
# http://seq.cloud
# This software is provided under an MIT License

# Abort on error
set -e

export SEQCLOUD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    return 1
fi

# Login scripts
where="${SEQCLOUD_DIR}/login"
for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort)
do
    . "$file"
done
unset -v file where
