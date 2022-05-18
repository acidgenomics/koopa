#!/usr/bin/env bash

koopa_install_openssl() {
    koopa_install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}
