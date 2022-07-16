#!/usr/bin/env bash

koopa_fedora_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='fedora' \
        --system \
        "$@"
}
