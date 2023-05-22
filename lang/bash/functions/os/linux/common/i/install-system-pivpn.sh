#!/usr/bin/env bash

koopa_linux_install_system_pivpn() {
    koopa_install_app \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}
