#!/usr/bin/env bash



# A                                                                         {{{1
# ==============================================================================

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



# F                                                                         {{{1
# ==============================================================================

# Find local bin directories.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-09-11.
_koopa_find_local_bin_dirs() {
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



# H                                                                         {{{1
# ==============================================================================

_koopa_help_args() {
cat << EOF
help arguments:
    --help, -h
        Show this help message and exit.
EOF
}



# Help header string.
# Updated 2019-09-25.
_koopa_help_header() {
    local file
    file="$( \
        caller | \
        head -n 1 | \
        cut -d ' ' -f 2 \
    )"
    local name
    name="$(basename "$file")"
    printf "usage: %s [--help|-h]" "$name"
}



# S                                                                         {{{1
# ==============================================================================

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
