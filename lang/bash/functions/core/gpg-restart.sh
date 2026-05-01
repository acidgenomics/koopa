#!/usr/bin/env bash

_koopa_gpg_restart() {
    # """
    # Restart GPG server.
    # @note Updated 2022-05-20.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    app['gpgconf']="$(_koopa_locate_gpgconf)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['gpgconf']}" --kill 'gpg-agent'
    return 0
}
