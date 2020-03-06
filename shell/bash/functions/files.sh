#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {  # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-03-06.
    # """
    local file files
    mapfile -t files <<< "$(_koopa_find_broken_symlinks "$@")"
    _koopa_is_array_non_empty "${files[@]}" || return 0
    for file in "${files[@]}"
    do
        [[ -z "$file" ]] && continue
        _koopa_rm "$file"
    done
    return 0
}

_koopa_remove_empty_dirs() {  # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-03-06.
    # """
    local dir dirs
    mapfile -t dirs <<< "$(_koopa_find_empty_dirs "$@")"
    _koopa_is_array_non_empty "${dirs[@]}" || return 0
    for dir in "${dirs[@]}"
    do
        [[ -z "$dir" ]] && continue
        _koopa_rm "$dir"
    done
    return 0
}
