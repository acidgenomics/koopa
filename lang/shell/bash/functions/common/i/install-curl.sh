#!/usr/bin/env bash

koopa_install_curl() {
    koopa_install_app \
        --link-in-bin='curl' \
        --link-in-bin='curl-config' \
        --name='curl' \
        "$@"
}
