#!/usr/bin/env bash

koopa_list_path_priority_unique() {
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2023-03-13.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    local -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['tac']="$(koopa_locate_tac)"
    )
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['tac']}" ]] || exit 1
    local -A dict
    dict['string']="${1:-$PATH}"
    # shellcheck disable=SC2016
    dict['string']="$( \
        koopa_print "${dict['string']//:/$'\n'}" \
        | "${app['tac']}" \
        | "${app['awk']}" '!a[$0]++' \
        | "${app['tac']}" \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
