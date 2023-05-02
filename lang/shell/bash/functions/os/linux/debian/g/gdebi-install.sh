#!/usr/bin/env bash

koopa_debian_gdebi_install() {
    # """
    # Install Debian binary using gdebi.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['gdebi']="$(koopa_debian_locate_gdebi --allow-missing)"
    if [[ ! -x "${app['gdebi']}" ]]
    then
        koopa_debian_apt_install 'gdebi-core'
        app['gdebi']="$(koopa_debian_locate_gdebi)"
    fi
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['gdebi']}" --non-interactive "$@"
    return 0
}
