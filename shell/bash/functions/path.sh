#!/usr/bin/env bash



# Add local builds to PATH (e.g. '/usr/local').
# This will recurse through the local library and find 'bin/' subdirs.
# Note: read `-a` flag doesn't work on macOS. zsh related?
# Modified 2019-06-20.
_koopa_bash_add_local_bins_to_path() {
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



# Find local bin directories.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-09-11.
_koopa_bash_find_local_bin_dirs() {
    local array
    array=()
    
    local tmp_file
    tmp_file="$(_koopa_tmp_dir)/find"

    find "$(_koopa_build_prefix)" \
        -mindepth 2 \
        -maxdepth 3 \
        -name "bin" \
        ! -path "*/Caskroom/*" \
        ! -path "*/Cellar/*" \
        ! -path "*/Homebrew/*" \
        ! -path "*/anaconda3/*" \
        ! -path "*/bcbio/*" \
        ! -path "*/lib/*" \
        ! -path "*/miniconda3/*" \
        -print0 > "$tmp_file"

    while IFS=  read -r -d $'\0'
    do
        array+=("$REPLY")
    done < "$tmp_file"
    rm -f "$tmp_file"

    # Sort the array.
    # > local sorted
    # SC2207: Prefer mapfile or read -a to split command output.
    # > IFS=$'\n' mapfile -t array < <(sort <<<"${array[*]}")
    # > unset IFS
    printf "%s\n" "${array[@]}"
}
