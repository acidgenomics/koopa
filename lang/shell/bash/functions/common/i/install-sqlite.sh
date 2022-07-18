#!/usr/bin/env bash

koopa_install_sqlite() {
    koopa_install_app \
        --link-in-bin='sqlite3' \
        --name='sqlite' \
        "$@"
}
