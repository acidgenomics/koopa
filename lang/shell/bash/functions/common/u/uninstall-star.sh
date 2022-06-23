#!/usr/bin/env bash

koopa_uninstall_star() {
    koopa_uninstall_app \
        --name='star' \
        --unlink-in-bin='STAR' \
        "$@"
}
