#!/usr/bin/env bash

_koopa_debian_os_codename() {
    # """
    # Debian operating system codename.
    # @note Updated 2023-02-14.
    # """
    local -A app dict
    app['lsb_release']="$(_koopa_debian_locate_lsb_release)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['lsb_release']}" -cs)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}
