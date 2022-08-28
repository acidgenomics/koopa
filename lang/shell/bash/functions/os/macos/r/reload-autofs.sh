#!/usr/bin/env bash

koopa_macos_reload_autofs() {
    # """
    # Reload autofs configuration defined in '/etc/auto_master'.
    # @note Updated 2021-10-27.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['automount']="$(koopa_macos_locate_automount)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['automount']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" "${app['automount']}" -vc
    return 0
}
