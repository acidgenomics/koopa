#!/usr/bin/env bash

koopa_macos_reload_autofs() {
    # """
    # Reload autofs configuration defined in '/etc/auto_master'.
    # @note Updated 2021-10-27.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['automount']="$(koopa_macos_locate_automount)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['automount']}" -vc
    return 0
}
