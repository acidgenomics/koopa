#!/usr/bin/env bash

koopa_linux_install_system_pihole() {
    koopa_install_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
