#!/usr/bin/env bash

_koopa_fedora_install_from_rpm() {
    # """
    # Install directly from RPM file.
    # @note Updated 2023-05-01.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['rpm']="$(_koopa_fedora_locate_rpm)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo \
        "${app['rpm']}" \
            -v \
            --force \
            --install \
            "$@"
    return 0
}
