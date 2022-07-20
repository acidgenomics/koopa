#!/usr/bin/env bash

koopa_install_r_packages() {
    koopa_install_app \
        --name='r-packages' \
        --no-prefix-check \
        "$@"
}
