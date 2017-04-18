#!/usr/bin/env bash
# seqcloud bash script loader
# (c) 2017 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

seqcloud_dir=${BASH_SOURCE%/*}

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    exit 1
fi

# Load profile settings
for file in $(find "$seqcloud_dir"/profile -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset file

# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$seqcloud_dir"/bash/"$script".sh $*
}
