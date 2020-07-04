#!/usr/bin/env bash

koopa::find_and_replace_in_files() { # {{{1
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
    koopa::assert_has_args_ge "$#" 3
    local file from to
    from="${1:?}"
    to="${2:?}"
    shift 2
    koopa::h1 "Replacing '${from}' with '${to}' in ${#} files."
    if { \
        koopa::str_match "${from}" '/' && ! koopa::str_match "${from}" '\/'; \
    } || { \
        koopa::str_match "${to}" '/' && ! koopa::str_match "${to}" '\/'; \
    }
    then
        koopa::stop "Unescaped slash detected."
    fi
    for file in "$@"
    do
        [ -f "$file" ] || return 1
        koopa::info "$file"
        sed -i "s/${from}/${to}/g" "$file"
    done
    return 0
}

koopa::remove_broken_symlinks() { # {{{1
    # """
    # Remove broken symlinks.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    local file files
    readarray -t files <<< "$(koopa::find_broken_symlinks "$@")"
    koopa::is_array_non_empty "${files[@]}" || return 0
    koopa::note "Removing ${#files[@]} broken symlinks."
    # Don't pass single call to rm, as argument list can be too long.
    for file in "${files[@]}"
    do
        [[ -z "$file" ]] && continue
        koopa::info "Removing '${file}'."
        rm -f "$file"
    done
    return 0
}

koopa::remove_empty_dirs() { # {{{1
    # """
    # Remove empty directories.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    local dirs
    readarray -t dirs <<< "$(koopa::find_empty_dirs "$@")"
    koopa::is_array_non_empty "${dirs[@]}" || return 0
    koopa::note "Removing ${#dirs[@]} empty directories."
    # Don't pass single call to rm, as argument list can be too long.
    for dir in "${dirs[@]}"
    do
        [[ -z "$dir" ]] && continue
        koopa::info "Removing '${dir}'."
        rm -fr "$dir"
    done
    return 0
}
