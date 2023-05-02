#!/usr/bin/env bash

koopa_update_system_tex_packages() {
    # """
    # Update TeX packages.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['tlmgr']="$(koopa_locate_tlmgr)"
    koopa_assert_is_executable "${app[@]}"
    (
        koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
        koopa_sudo "${app['tlmgr']}" update --self
        koopa_sudo "${app['tlmgr']}" update --list
        koopa_sudo "${app['tlmgr']}" update --all
    )
    return 0
}
