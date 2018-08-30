#!/usr/bin/env bash

# koopa shell bootloader
# (c) 2018 Michael Steinbaugh
# This software is provided under an MIT License.

export KOOPA_VERSION="0.1.1"
export KOOPA_DATE="2018-08-24"

export KOOPA_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    return 1
fi

# Login scripts
where="${KOOPA_DIR}/login"
for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort)
do
    . "$file"
done
unset -v file where
