#!/usr/bin/env bash

koopa_has_ssl_cert_file() {
    # """
    # Does the current environment have custom CA certificates loaded?
    # @note Updated 2026-01-02.
    # """
    local -A dict
    dict['ssl_cert_file']="${SSL_CERT_FILE:-}"
    if [[ -z "${dict['ssl_cert_file']}" ]]
    then
        return 1
    fi
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    if [[ "${dict['ssl_cert_file']}" == "${dict['koopa_prefix']}/"* ]]
    then
        return 1
    fi
    return 0
}
