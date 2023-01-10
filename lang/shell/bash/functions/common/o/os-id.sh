#!/usr/bin/env bash

koopa_os_id() {
    # """
    # Operating system ID.
    # @note Updated 2023-01-10.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app dict
    app['cut']="$(koopa_locate_cut --allow-system)"
    [[ -x "${app['cut']}" ]] || return 1
    dict['string']="$( \
        koopa_os_string \
        | "${app['cut']}" -d '-' -f '1' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
