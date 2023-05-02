#!/usr/bin/env bash

koopa_debian_apt_remove() {
    # """
    # Remove Debian apt package.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo \
        "${app['apt_get']}" --yes remove --purge "$@"
    koopa_debian_apt_clean
    return 0
}
