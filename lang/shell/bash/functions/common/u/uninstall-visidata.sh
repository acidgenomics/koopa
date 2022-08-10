#!/usr/bin/env bash

koopa_uninstall_visidata() {
    koopa_uninstall_app \
        --name='visidata' \
        --unlink-in-bin='vd' \
        --unlink-in-bin='visidata' \
        "$@"
}
