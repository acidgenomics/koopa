#!/usr/bin/env bash



# Add local builds to PATH (e.g. '/usr/local').
#
# This will recurse through the local library and find 'bin/' subdirs.
#
# Note: read `-a` flag doesn't work on macOS. zsh related?
#
# Updated 2019-06-20.
_koopa_add_local_bins_to_path() {
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_build_prefix)/bin"
    IFS=$'\n'
    read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
}



