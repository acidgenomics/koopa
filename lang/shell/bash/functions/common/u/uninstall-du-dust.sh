#!/usr/bin/env bash

koopa_uninstall_du_dust() {
    koopa_uninstall_app \
        --name='du-dust' \
        --unlink-in-bin='dust' \
        "$@"
}
