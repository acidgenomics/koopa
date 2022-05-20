#!/usr/bin/env bash

koopa_uninstall_mdcat() {
    koopa_uninstall_app \
        --name='mdcat' \
        --unlink-in-bin='mdcat' \
        "$@"
}
