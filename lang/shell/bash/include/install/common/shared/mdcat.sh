#!/usr/bin/env bash

main() {
    # """
    # Install mdcat.
    # @note Updated 2023-04-12.
    # """
    koopa_activate_app 'openssl3'
    OPENSSL_DIR="$(koopa_app_prefix 'openssl3')"
    export OPENSSL_DIR
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='mdcat'
}
