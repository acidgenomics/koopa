#!/usr/bin/env bash

koopa_rg_unique() {
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['rg']="$(koopa_locate_rg)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    dict['str']="$( \
        "${app['rg']}" \
            --no-filename \
            --no-line-number \
            --only-matching \
            --sort 'none' \
            "${dict['pattern']}" \
        | "${app['sort']}" --unique \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
