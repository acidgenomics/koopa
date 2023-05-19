#!/usr/bin/env bash

koopa_gpg_reload() {
    # """
    # Force reload the GPG server.
    # @note Updated 2022-05-20.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpg_connect_agent']="$(koopa_locate_gpg_connect_agent)"
    koopa_assert_is_executable "${app[@]}"
    "${app['gpg_connect_agent']}" reloadagent '/bye'
    return 0
}
