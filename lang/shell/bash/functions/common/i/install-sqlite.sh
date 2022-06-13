#!/usr/bin/env bash

koopa_install_sqlite() {
    koopa_install_app \
        --link-in-bin='bin/sqlite3' \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}
