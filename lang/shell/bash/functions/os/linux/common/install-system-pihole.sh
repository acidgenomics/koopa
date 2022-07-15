#!/usr/bin/env bash

koopa_linux_install_system_pihole() {
    koopa_update_app \
        --name-fancy='Pi-hole' \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
