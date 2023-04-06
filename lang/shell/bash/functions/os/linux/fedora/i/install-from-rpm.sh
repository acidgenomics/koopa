#!/usr/bin/env bash

koopa_fedora_install_from_rpm() {
    # """
    # Install directly from RPM file.
    # @note Updated 2023-04-05.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['rpm']="$(koopa_fedora_locate_rpm)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['rpm']}" -v \
        --force \
        --install \
        "$@"
    return 0
}
