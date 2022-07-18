#!/usr/bin/env bash

koopa_uninstall_curl() {
    koopa_uninstall_app \
        --name='curl' \
        --unlink-in-bin='curl' \
        --unlink-in-bin='curl-config' \
        "$@"
}
