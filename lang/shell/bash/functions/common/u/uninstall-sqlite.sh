#!/usr/bin/env bash

koopa_uninstall_sqlite() {
    koopa_uninstall_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}
