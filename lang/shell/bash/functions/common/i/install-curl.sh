#!/usr/bin/env bash

koopa_install_curl() {
    koopa_install_app \
        --link-in-bin='bin/curl' \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}
