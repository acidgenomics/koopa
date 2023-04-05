#!/usr/bin/env bash

koopa_list_path_priority_unique() {
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['awk']="$(koopa_locate_awk)"
    app['tac']="$(koopa_locate_tac)"
    koopa_assert_is_executable "${app[@]}"
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
