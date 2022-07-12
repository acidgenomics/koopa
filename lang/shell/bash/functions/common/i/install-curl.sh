#!/usr/bin/env bash

koopa_install_curl() {
    koopa_install_app \
        --link-in-bin='bin/curl' \
        --link-in-bin='bin/curl-config' \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}
