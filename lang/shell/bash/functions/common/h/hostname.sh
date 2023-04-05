#!/usr/bin/env bash

koopa_hostname() {
    # """
    # Host name.
    # @note Updated 2023-03-11.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app dict
    app['uname']="$(koopa_locate_uname)"
    [[ -x "${app['uname']}" ]] || exit 1
    dict['string']="$("${app['uname']}" -n)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
