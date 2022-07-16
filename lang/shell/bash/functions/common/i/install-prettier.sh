#!/usr/bin/env bash

koopa_install_prettier() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='prettier' \
        --name='prettier' \
        "$@"
}
