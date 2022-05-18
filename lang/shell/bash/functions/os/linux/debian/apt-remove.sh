#!/usr/bin/env bash

koopa_debian_apt_remove() {
    # """
    # Remove Debian apt package.
    # @note Updated 2021-11-02.
    # """
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove --purge "$@"
    koopa_debian_apt_clean
    return 0
}
