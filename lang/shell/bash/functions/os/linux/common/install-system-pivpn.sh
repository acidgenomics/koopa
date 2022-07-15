#!/usr/bin/env bash

koopa_linux_install_system_pivpn() {
    koopa_update_app \
        --name-fancy='PiVPN' \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}
