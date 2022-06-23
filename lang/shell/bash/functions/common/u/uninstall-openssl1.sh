#!/usr/bin/env bash

koopa_uninstall_openssl1() {
    koopa_uninstall_app \
        --name-fancy='OpenSSL (v1)' \
        --name='openssl1' \
        "$@"
}
