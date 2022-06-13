#!/usr/bin/env bash

koopa_uninstall_zellij() {
    koopa_uninstall_app \
        --unlink-in-bin='zellij' \
        --name='zellij' \
        "$@"
}
