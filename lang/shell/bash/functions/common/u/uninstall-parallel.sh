#!/usr/bin/env bash

koopa_uninstall_parallel() {
    koopa_uninstall_app \
        --name='parallel' \
        --unlink-in-bin='parallel' \
        "$@"
}
