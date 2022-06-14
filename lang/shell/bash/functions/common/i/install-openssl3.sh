#!/usr/bin/env bash

koopa_install_openssl3() {
    koopa_install_app \
        --name-fancy='OpenSSL (v3)' \
        --name='openssl3' \
        "$@"
}
