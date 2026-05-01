#!/usr/bin/env bash

_koopa_debian_install_from_deb() {
    # """
    # Install directly from a '.deb' file.
    # @note Updated 2023-05-01.
    # """
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['gdebi']="$(_koopa_debian_locate_gdebi --allow-missing)"
    if [[ ! -x "${app['gdebi']}" ]]
    then
        _koopa_debian_apt_install 'gdebi-core'
        app['gdebi']="$(_koopa_debian_locate_gdebi)"
    fi
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['gdebi']}" --non-interactive "$@"
    return 0
}
