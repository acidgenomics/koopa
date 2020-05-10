#!/usr/bin/env bash

_koopa_remove_broken_symlinks() {  # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-05-10.
    # """
    local file files
    mapfile -t files <<< "$(_koopa_find_broken_symlinks "$@")"
    _koopa_is_array_non_empty "${files[@]}" || return 0
    _koopa_note "Removing ${#files[@]} broken symlinks."
    # Don't pass single call to rm, as argument list can be too long.
    for file in "${files[@]}"
    do
        [[ -z "$file" ]] && continue
        _koopa_info "Removing '${file}'."
        rm -f "$file"
    done
    return 0
}

_koopa_remove_empty_dirs() {  # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-05-10.
    # """
    local dirs
    mapfile -t dirs <<< "$(_koopa_find_empty_dirs "$@")"
    _koopa_is_array_non_empty "${dirs[@]}" || return 0
    _koopa_note "Removing ${#dirs[@]} empty directories."
    # Don't pass single call to rm, as argument list can be too long.
    for dir in "${dirs[@]}"
    do
        [[ -z "$dir" ]] && continue
        _koopa_info "Removing '${dir}'."
        rm -fr "$dir"
    done
    return 0
}
