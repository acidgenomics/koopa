#!/usr/bin/env bash

_koopa_add_local_bins_to_path() {  # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2019-10-22.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS. zsh related?
    # """
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_make_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_find_local_bin_dirs() {  # {{{1
    # """
    # Find local bin directories.
    # @note Updated 2020-02-02.
    #
    # Alternate array sorting methods:
    # > readarray -t array < <( \
    # >     printf '%s\0' "${array[@]}" \
    # >     | sort -z \
    # >     | xargs -0n1 \
    # > )
    #
    # > IFS=$'\n' array=($(sort <<<"${array[*]}"))
    # > unset IFS
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    # """
    local array
    array=()
    while IFS= read -r -d $'\0'
    do
        array+=("$REPLY")
    done < <( \
        find "$(_koopa_make_prefix)" \
            -mindepth 2 \
            -maxdepth 3 \
            -type d \
            -name "bin" \
            ! -path "*/Caskroom/*" \
            ! -path "*/Cellar/*" \
            ! -path "*/Homebrew/*" \
            ! -path "*/anaconda3/*" \
            ! -path "*/bcbio/*" \
            ! -path "*/lib/*" \
            ! -path "*/miniconda3/*" \
            -print0 \
        | sort -z
    )
    printf "%s\n" "${array[@]}"
}

_koopa_is_array_non_empty() {  # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2019-10-22.
    #
    # Particularly useful for checking against mapfile return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # """
    local arr
    arr=("$@")
    [[ "${#arr[@]}" -eq 0 ]] && return 1
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}

_koopa_script_name() {  # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2019-10-22.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local file
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    basename "$file"
}
