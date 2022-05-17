#!/usr/bin/env bash

koopa_uninstall_curl() {
    koopa_uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        --unlink-in-bin='curl' \
        "$@"
}
