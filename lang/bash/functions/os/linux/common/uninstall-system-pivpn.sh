#!/usr/bin/env bash

_koopa_linux_uninstall_system_pivpn() {
    _koopa_uninstall_app \
        --name='pivpn' \
        --system \
        "$@"
}
