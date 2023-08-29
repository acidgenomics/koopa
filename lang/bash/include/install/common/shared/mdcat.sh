#!/usr/bin/env bash

main() {
    # """
    # Install mdcat.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    koopa_activate_app 'openssl3'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    OPENSSL_DIR="${dict['openssl']}"
    export OPENSSL_DIR
    koopa_install_rust_package \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --version="${dict['version']}"
    return 0
}
