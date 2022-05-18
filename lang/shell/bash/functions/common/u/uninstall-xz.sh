#!/usr/bin/env bash

koopa_uninstall_xz() {
    koopa_uninstall_app \
        --name='xz' \
        --unlink-in-bin='xz' \
        "$@"
}
