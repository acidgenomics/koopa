#!/usr/bin/env bash
# seqcloud bash script loader
# (c) 2017 Michael J. Steinbaugh
# This software is provided under an MIT License
# http://seq.cloud

# http://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
# seqcloud_dir=${BASH_SOURCE%/*}
seqcloud_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check for supported operating system
if [[ $(uname -s) != "Linux" ]] && [[ $(uname -s) != "Darwin" ]]; then
    echo "$(uname -s) operating system not supported"
    exit 1
fi

echo ""
echo "  ==== seqcloud ========================================================  "
echo ""

# Load profile settings
for file in $(find "$seqcloud_dir"/profile -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset file

echo ""
echo "  ======================================================================  "
echo ""

# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$seqcloud_dir"/bash/"$script".sh $*
}
