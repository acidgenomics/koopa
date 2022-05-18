#!/usr/bin/env bash

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2021-11-02.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    local app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" update
    "${app[sudo]}" DEBIAN_FRONTEND='noninteractive' \
        "${app[apt_get]}" \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}
