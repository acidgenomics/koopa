#!/usr/bin/env bash

koopa_gpg_restart() {
    # """
    # Restart GPG server.
    # @note Updated 2022-05-20.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpgconf']="$(koopa_locate_gpgconf)"
    koopa_assert_is_executable "${app[@]}"
    "${app['gpgconf']}" --kill 'gpg-agent'
    return 0
}
