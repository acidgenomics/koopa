#!/usr/bin/env bash

koopa_uninstall_deeptools() {
    koopa_uninstall_app \
        --name='deeptools' \
        --unlink-in-bin='deeptools' \
        "$@"
}
