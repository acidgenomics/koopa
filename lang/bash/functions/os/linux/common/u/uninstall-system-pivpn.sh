#!/usr/bin/env bash

koopa_linux_uninstall_system_pivpn() {
    koopa_uninstall_app \
        --name='pivpn' \
        --system \
        "$@"
}
