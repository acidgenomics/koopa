#!/usr/bin/env bash

koopa_uninstall_gtop() {
    koopa_uninstall_app \
        --name='gtop' \
        --unlink-in-bin='gtop' \
        "$@"
}
