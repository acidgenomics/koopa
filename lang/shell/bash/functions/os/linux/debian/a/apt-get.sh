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
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['apt_get']}" update
    "${app['sudo']}" DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}
