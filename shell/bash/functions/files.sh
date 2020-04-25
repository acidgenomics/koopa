#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {  # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-04-25.
    # """
    local files
    mapfile -t files <<< "$(_koopa_find_broken_symlinks "$@")"
    _koopa_is_array_non_empty "${files[@]}" || return 0
    _koopa_note "Removing ${#files[@]} broken symlinks."
    _koopa_rm "${files[@]}"
    return 0
}

_koopa_remove_empty_dirs() {  # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-04-25.
    # """
    local dirs
    mapfile -t dirs <<< "$(_koopa_find_empty_dirs "$@")"
    _koopa_is_array_non_empty "${dirs[@]}" || return 0
    _koopa_note "Removing ${#dirs[@]} empty directories."
    _koopa_rm "${dirs[@]}"
    return 0
}
