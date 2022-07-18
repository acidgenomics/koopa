#!/usr/bin/env bash

koopa_alpine_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='alpine' \
        --system \
        "$@"
}
