#!/usr/bin/env bash

koopa_uninstall_tuc() {
    koopa_uninstall_app \
        --unlink-in-bin='tuc' \
        --name='tuc' \
        "$@"
}
