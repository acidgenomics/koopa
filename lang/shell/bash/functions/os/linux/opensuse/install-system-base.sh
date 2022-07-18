#!/usr/bin/env bash

koopa_opensuse_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='opensuse' \
        --system \
        "$@"
}
