#!/usr/bin/env bash

_koopa_hostname() {
    # """
    # Host name.
    # @note Updated 2024-09-05.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['uname']="$(_koopa_locate_uname --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['uname']}" -n)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}
