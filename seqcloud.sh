#!/usr/bin/env bash

# seqcloud bash shell boatloader
# (c) 2018 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

export SEQCLOUD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    exit 1
fi

# Load profile settings
. "$SEQCLOUD_DIR"/profile/general.sh
if [[ "$SEQCLOUD_CONSOLE" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/console \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi
if [[ "$SEQCLOUD_PATH" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/path \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi

# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$SEQCLOUD_DIR"/scripts/"$script".sh $*
}

# Login message for interactive session
. "$SEQCLOUD_DIR"/login/hpc_interactive_message.sh
