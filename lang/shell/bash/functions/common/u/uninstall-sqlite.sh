#!/usr/bin/env bash

koopa_uninstall_sqlite() {
    koopa_uninstall_app \
        --name='sqlite' \
        --unlink-in-bin='sqlite3' \
        "$@"
}
