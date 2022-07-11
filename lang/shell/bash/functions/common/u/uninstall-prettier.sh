#!/usr/bin/env bash

koopa_uninstall_prettier() {
    koopa_uninstall_app \
        --name='prettier' \
        --unlink-in-bin='prettier' \
        "$@"
}
