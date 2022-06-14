#!/usr/bin/env bash

koopa_install_openssl_v1() {
    koopa_install_app \
        --name-fancy='OpenSSL (v1)' \
        --name='openssl-v1' \
        "$@"
}
