#!/usr/bin/env bash

koopa_rg_sort() {
    # """
    # ripgrep sorted.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['rg']="$(koopa_locate_rg)"
    koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    dict['str']="$( \
        "${app['rg']}" \
            --pretty \
            --sort 'path' \
            "${dict['pattern']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
