#!/usr/bin/env bash

koopa::rg_sort() { # {{{1
    # """
    # ripgrep sorted.
    # @note Updated 2022-01-20.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [rg]="$(koopa::locate_rg)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
    )
    dict[str]="$( \
        "${app[rg]}" \
            --pretty \
            --sort 'path' \
            "${dict[pattern]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}

koopa::rg_unique() { # {{{1
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2022-01-20.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [rg]="$(koopa::locate_rg)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
    )
    dict[str]="$( \
        "${app[rg]}" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "${dict[pattern]}" \
        | "${app[sort]}" --unique \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}
