#!/usr/bin/env bash
# koopa nolint=illegal-strings

koopa::rg_fixme() { # {{{1
    # """
    # ripgrep for 'FIXME' string.
    # @note Updated 2021-05-24.
    # """
    local pattern x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'rg'
    pattern='FIXME'
    x="$( \
        rg \
        --files-with-matches \
        --sort 'path' \
        "$pattern" \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

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
