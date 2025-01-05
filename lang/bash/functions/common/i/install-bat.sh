#!/usr/bin/env bash

koopa_install_bat() {
    koopa_install_app \
        --installer='conda-package' \
        --name='bat' \
        "$@"
}
