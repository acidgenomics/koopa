#!/usr/bin/env bash

_koopa_update_system_tex_packages() {
    # """
    # Update TeX packages.
    # @note Updated 2023-05-01.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['tlmgr']="$(_koopa_locate_tlmgr)"
    _koopa_assert_is_executable "${app[@]}"
    (
        _koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
        _koopa_sudo "${app['tlmgr']}" update --self
        _koopa_sudo "${app['tlmgr']}" update --list
        _koopa_sudo "${app['tlmgr']}" update --all
    )
    return 0
}
