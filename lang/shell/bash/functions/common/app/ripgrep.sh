#!/usr/bin/env bash

koopa::rg_unique() { # {{{1
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2021-05-08.
    # """
    local pattern
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed rg
    pattern="${1:?}"
    x="$( \
        rg \
            --no-filename \
            --no-line-number \
            --only-matching "$pattern" \
        | sort -u \
    )"
    koopa::print "$x"
    return 0
}
