#!/usr/bin/env bash

koopa_hostname() {
    # """
    # Host name.
    # @note Updated 2023-03-11.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['uname']="$(koopa_locate_uname)"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['uname']}" -n)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
