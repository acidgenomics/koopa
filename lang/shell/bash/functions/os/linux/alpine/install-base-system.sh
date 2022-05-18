#!/usr/bin/env bash

koopa_alpine_install_base_system() {
    koopa_install_app \
        --name-fancy='Alpine base system' \
        --name='base-system' \
        --platform='alpine' \
        --system \
        "$@"
}
