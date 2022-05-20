#!/usr/bin/env bash

koopa_debian_gdebi_install() {
    # """
    # Install Debian binary using gdebi.
    # @note Updated 2022-04-26.
    # """
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa_debian_locate_gdebi)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "$@"
    return 0
}
