#!/usr/bin/env bash

koopa_debian_os_codename() {
    # """
    # Debian operating system codename.
    # @note Updated 2022-01-10.
    # """
    local app dict
    declare -A app dict
    app['lsb_release']="$(koopa_locate_lsb_release)"
    [[ -x "${app['lsb_release']}" ]] || return 1
    dict['string']="$("${app['lsb_release']}" -cs)"
    [ -n "${dict['string']}" ] || return 1
    koopa_print "${dict['string']}"
    return 0
}
