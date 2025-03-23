#!/usr/bin/env bash

koopa_install_fish() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fish' \
        "$@"
}
