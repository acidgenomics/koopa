#!/usr/bin/env bash

koopa_uninstall_procs() {
    koopa_uninstall_app \
        --name='procs' \
        --unlink-in-bin='procs' \
        "$@"
}
