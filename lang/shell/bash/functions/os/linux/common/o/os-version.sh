#!/usr/bin/env bash

koopa_linux_os_version() {
    # """
    # Linux OS version.
    # @note Updated 2022-08-30.
    # """
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app
    app['uname']="$(koopa_locate_uname --allow-system)"
    [[ ! -x "${app['uname']}" ]] && app['uname']='/usr/bin/uname'
    [[ -x "${app['uname']}" ]] || return 1
    x="$("${app['uname']}" -r)"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
