#!/usr/bin/env bash

koopa_linux_uninstall_system_pihole() {
    koopa_uninstall_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
