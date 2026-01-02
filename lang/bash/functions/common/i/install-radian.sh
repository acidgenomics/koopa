#!/usr/bin/env bash

koopa_install_radian() {
    koopa_install_app \
        --installer='conda-package' \
        --name='radian' \
        "$@"
}
