#!/usr/bin/env bash

koopa_has_ssl_cert_file() {
    # """
    # Does the current environment have a custom CA certificates file?
    # @note Updated 2025-12-08.
    # """
    [ -n "${SSL_CERT_FILE:-}" ]
}
