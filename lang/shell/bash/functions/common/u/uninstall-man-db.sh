#!/usr/bin/env bash

koopa_uninstall_man_db() {
    koopa_uninstall_app \
        --name='man-db' \
        --unlink-in-bin='man' \
        "$@"
}
