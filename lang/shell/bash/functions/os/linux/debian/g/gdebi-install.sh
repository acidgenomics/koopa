#!/usr/bin/env bash

koopa_debian_gdebi_install() {
    # """
    # Install Debian binary using gdebi.
    # @note Updated 2023-03-21.
    # """
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['sudo']}" ]] || exit 1
    app['gdebi']="$(koopa_debian_locate_gdebi --allow-missing)"
    if [[ ! -x "${app['gdebi']}" ]]
    then
        koopa_debian_apt_install 'gdebi-core'
        app['gdebi']="$(koopa_debian_locate_gdebi)"
    fi
    [[ -x "${app['gdebi']}" ]] || exit 1
    "${app['sudo']}" "${app['gdebi']}" --non-interactive "$@"
    return 0
}
