#!/usr/bin/env bash

_koopa_find_and_replace_in_files() { # {{{1
    # """
    # Find and replace inside files.
    # @note Updated 2020-07-01.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    # https://stackoverflow.com/questions/4247068/
    # """
    [ "$#" -ge 3 ] || return 1
    local file from to
    from="${1:?}"
    to="${2:?}"
    shift 2
    _koopa_h1 "Replacing '${from}' with '${to}' in ${#} files."
    if { \
        _koopa_str_match "${from}" '/' && ! _koopa_str_match "${from}" '\/'; \
    } || { \
        _koopa_str_match "${to}" '/' && ! _koopa_str_match "${to}" '\/'; \
    }
    then
        _koopa_stop "Unescaped slash detected."
    fi
    for file in "$@"
    do
        [ -f "$file" ] || return 1
        _koopa_info "$file"
        sed -i "s/${from}/${to}/g" "$file"
    done
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
