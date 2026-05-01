#!/usr/bin/env bash

_koopa_rg_unique() {
    # """
    # ripgrep, but only return a summary of all unique matches.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['rg']="$(_koopa_locate_rg)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
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
    _koopa_print "${dict['str']}"
    return 0
}
