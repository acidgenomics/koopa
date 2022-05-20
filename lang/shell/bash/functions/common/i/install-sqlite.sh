#!/usr/bin/env bash

koopa_install_sqlite() {
    koopa_install_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}
