#!/usr/bin/env bash

_koopa_macos_reload_autofs() {
    # """
    # Reload autofs configuration defined in '/etc/auto_master'.
    # @note Updated 2021-10-27.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['automount']="$(_koopa_macos_locate_automount)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['automount']}" -vc
    return 0
}
