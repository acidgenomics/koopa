#!/usr/bin/env bash

koopa_linux_update_ldconfig() {
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2022-10-06.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['ldconfig']="$(koopa_linux_locate_ldconfig)"
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['ldconfig']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['ldconfig']}" || true
    return 0
}
