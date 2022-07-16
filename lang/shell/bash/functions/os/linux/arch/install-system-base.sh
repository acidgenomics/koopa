#!/usr/bin/env bash

koopa_arch_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='arch' \
        --system \
        "$@"
}
