#!/usr/bin/env bash

koopa_rg_sort() {
    # """
    # ripgrep sorted.
    # @note Updated 2022-01-20.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [rg]="$(koopa_locate_rg)"
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
    koopa_print "${dict[str]}"
    return 0
}
