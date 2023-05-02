#!/usr/bin/env bash

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2023-05-01.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['apt_get']}" update
    koopa_sudo \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}
