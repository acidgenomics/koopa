#!/usr/bin/env bash

koopa_debian_apt_space_used_by() {
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # Alternate approach that doesn't attempt to grep match.
    # """
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['apt_get']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['apt_get']}" --assume-no autoremove "$@"
    return 0
}
