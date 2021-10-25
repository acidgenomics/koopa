#!/usr/bin/env bash

koopa::rg_sort() { # {{{1
    # """
    # ripgrep sorted.
    # @note Updated 2021-10-25.
    # """
    local pattern rg x
    koopa::assert_has_args_eq "$#" 1
    rg="$(koopa::locate_rg)"
    pattern="${1:?}"
    x="$( \
        "$rg" \
            --pretty \
            --sort 'path' \
            "$pattern" \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::rg_unique() { # {{{1
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2021-10-25.
    # """
    local pattern rg sort x
    koopa::assert_has_args_eq "$#" 1
    rg="$(koopa::locate_rg)"
    sort="$(koopa::locate_sort)"
    pattern="${1:?}"
    x="$( \
        "$rg" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "$pattern" \
        | "$sort" --unique \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
