#!/usr/bin/env bash

koopa_install_openssl3() {
    koopa_install_app \
        --link-in-bin='openssl' \
        --name='openssl3' \
        "$@"
}
