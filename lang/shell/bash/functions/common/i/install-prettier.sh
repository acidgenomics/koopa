#!/usr/bin/env bash

koopa_install_prettier() {
    koopa_install_app \
        --link-in-bin='prettier' \
        --name='prettier' \
        "$@"
}
