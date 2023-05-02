#!/usr/bin/env bash

koopa_linux_update_ldconfig() {
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['ldconfig']="$(koopa_linux_locate_ldconfig)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['ldconfig']}" || true
    return 0
}
