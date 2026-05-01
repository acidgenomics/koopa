#!/usr/bin/env bash

_koopa_linux_update_ldconfig() {
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2023-05-01.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    app['ldconfig']="$(_koopa_linux_locate_ldconfig)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['ldconfig']}" || true
    return 0
}
