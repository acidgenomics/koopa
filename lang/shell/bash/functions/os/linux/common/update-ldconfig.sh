#!/usr/bin/env bash

koopa_linux_update_ldconfig() {
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2022-10-06.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['ldconfig']="$(koopa_linux_locate_ldconfig)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['ldconfig']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" "${app['ldconfig']}" || true
    return 0
}
