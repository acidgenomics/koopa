#!/usr/bin/env bash
# seqcloud bash script loader
# (c) 2017 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

seqcloudDir=${BASH_SOURCE%/*}

# Load profile settings
for file in $(find "$seqcloudDir"/profile -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done

# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$seqcloudDir"/bash/"$script".sh $*
}
