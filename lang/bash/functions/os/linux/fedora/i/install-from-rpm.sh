#!/usr/bin/env bash

koopa_fedora_install_from_rpm() {
    # """
    # Install directly from RPM file.
    # @note Updated 2023-05-01.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['rpm']="$(koopa_fedora_locate_rpm)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo \
        "${app['rpm']}" \
            -v \
            --force \
            --install \
            "$@"
    return 0
}
