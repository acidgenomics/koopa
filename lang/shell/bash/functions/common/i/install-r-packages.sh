#!/usr/bin/env bash

koopa_install_r_packages() {
    koopa_install_app_packages \
        --name-fancy='R' \
        --name='r' \
        "$@"
}
