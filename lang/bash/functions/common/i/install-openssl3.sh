#!/usr/bin/env bash

koopa_install_openssl3() {
    koopa_install_app \
        --installer='openssl' \
        --name='openssl3' \
        "$@"
}
