#!/usr/bin/env bash

koopa_install_man_db() {
    koopa_install_app \
        --link-in-bin='bin/man' \
        --name='man-db' \
        "$@"
}
