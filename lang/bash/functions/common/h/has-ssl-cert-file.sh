#!/usr/bin/env bash

koopa_has_ssl_cert_file() {
    # """
    # Does the current environment have custom CA certificates loaded?
    # @note Updated 2026-01-02.
    # """
    if [[ -z "${SSL_CERT_FILE:-}" ]]
    then
        return 1
    fi
    if [[ "${SSL_CERT_FILE:?}" == "${KOOPA_PREFIX:?}/"* ]]
    then
        return 1
    fi
    return 0
}
