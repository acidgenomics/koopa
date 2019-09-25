#!/usr/bin/env bash



# Get the calling script name.
# Updated 2019-09-25.
_koopa_script_name() {
    local file
    file="$( \
        caller | \
        head -n 1 | \
        cut -d ' ' -f 2 \
    )"
    basename "$file"
}
