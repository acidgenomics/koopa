#!/usr/bin/env bash

# FIXME Duplicated with 'gdebi-install'?

koopa_debian_install_from_deb() {
    # """
    # Install directly from a '.deb' file.
    # @note Updated 2023-05-01.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_admin
    app['gdebi']="$(koopa_debian_locate_gdebi)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:?}"
    koopa_sudo "${app['gdebi']}" --non-interactive "${dict['file']}"
    return 0
}
