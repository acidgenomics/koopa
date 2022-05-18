#!/usr/bin/env bash

koopa_debian_install_from_deb() {
    # """
    # Install directly from a '.deb' file.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa_debian_locate_gdebi)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "${dict[file]}"
    return 0
}
