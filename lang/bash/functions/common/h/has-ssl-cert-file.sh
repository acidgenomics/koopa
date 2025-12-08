#!/usr/bin/env bash

koopa_has_ssl_cert_file() {
    # """
    # Does the current environment have custom CA certificates loaded?"
    # @note Updated 2025-12-08.
    # """
    [[ -n "${SSL_CERT_FILE:-}" ]]
}
