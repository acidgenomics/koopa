#!/usr/bin/env bash

koopa_install_julia_packages() {
    koopa_install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}
