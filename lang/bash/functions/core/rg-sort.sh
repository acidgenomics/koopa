#!/usr/bin/env bash

_koopa_rg_sort() {
    # """
    # ripgrep sorted.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['rg']="$(_koopa_locate_rg)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']="${1:?}"
    dict['str']="$( \
        "${app['rg']}" \
            --pretty \
            --sort 'path' \
            "${dict['pattern']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
