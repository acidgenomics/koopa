#!/usr/bin/env bash

koopa_uninstall_zoxide() {
    koopa_uninstall_app \
        --unlink-in-bin='zoxide' \
        --name='zoxide' \
        "$@"
}
