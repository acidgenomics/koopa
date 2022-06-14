#!/usr/bin/env bash

koopa_install_openssl1() {
    koopa_install_app \
        --name-fancy='OpenSSL (v1)' \
        --name='openssl1' \
        "$@"
}
