#!/usr/bin/env bash

koopa_gpg_restart() {
    # """
    # Restart GPG server.
    # @note Updated 2022-05-20.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpgconf']="$(koopa_locate_gpgconf)"
    [[ -x "${app['gpgconf']}" ]] || exit 1
    "${app['gpgconf']}" --kill 'gpg-agent'
    return 0
}
