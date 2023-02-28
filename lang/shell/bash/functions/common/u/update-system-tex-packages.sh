#!/usr/bin/env bash

koopa_update_system_tex_packages() {
    # """
    # Update TeX packages.
    # @note Updated 2023-02-28.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
        ['tlmgr']="$(koopa_locate_tlmgr)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tlmgr']}" ]] || return 1
    (
        koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
        "${app['sudo']}" "${app['tlmgr']}" update --self
        "${app['sudo']}" "${app['tlmgr']}" update --list
        "${app['sudo']}" "${app['tlmgr']}" update --all
    )
    return 0
}
