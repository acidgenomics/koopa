#!/usr/bin/env bash

# FIXME Need to locate rg.
koopa::rg_sort() { # {{{1
    # """
    # ripgrep sorted.
    # @note Updated 2021-05-24.
    # """
    local pattern x
    koopa::assert_has_args "$#" 1
    koopa::assert_is_installed 'rg'
    pattern="${1:?}"
    x="$( \
        rg \
            --pretty \
            --sort 'path' \
            "$pattern" \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

# FIXME Need to locate rg.
koopa::rg_unique() { # {{{1
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2021-05-24.
    # """
    local pattern x
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed 'rg'
    pattern="${1:?}"
    x="$( \
        rg \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'path' \
            "$pattern" \
    )"
    koopa::print "$x"
    return 0
}
