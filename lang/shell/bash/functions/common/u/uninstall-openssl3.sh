#!/usr/bin/env bash

koopa_uninstall_openssl3() {
    koopa_uninstall_app \
        --name-fancy='OpenSSL (v3)' \
        --name='openssl3' \
        "$@"
}
