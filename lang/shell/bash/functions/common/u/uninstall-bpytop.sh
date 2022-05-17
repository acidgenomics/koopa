#!/usr/bin/env bash

koopa_uninstall_bpytop() {
    koopa_uninstall_app \
        --name='bpytop' \
        --unlink-in-bin='bpytop' \
        "$@"
}
