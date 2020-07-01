#!/usr/bin/env bash

## FIXME USE RIPGREP IF INSTALLED.
## FIXME ALLOW FLAGS HERE, FASTER
## FIXME WARN IF RIPGREP ISNT INSTALLED
_koopa_find_text() { # {{{1
    # """
    # Find text in any file.
    # @note Updated 2020-07-01.
    #
    # See also: https://github.com/stephenturner/oneliners
    #
    # Examples:
    # _koopa_find_text "mytext" *.txt
    # """
    [ "$#" -ge 2 ] && [ "$#" -le 3 ] || return 1
    _koopa_is_installed find grep || return 1
    local dir name_glob pattern x
    pattern="${1:?}"
    name_glob="${2:?}"
    dir="${3:-"."}"
    dir="$(realpath "$dir")"
    x="$( \
        find "$dir" \
            -mindepth 1 \
            -type f \
            -name "$name_glob" \
            -exec grep -il "$pattern" {} \;; \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_remove_broken_symlinks() { # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    local file files
    readarray -t files <<< "$(_koopa_find_broken_symlinks "$@")"
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

_koopa_remove_empty_dirs() { # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    local dirs
    readarray -t dirs <<< "$(_koopa_find_empty_dirs "$@")"
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
