#!/usr/bin/env bash

_koopa_linux_install_system_pivpn() {
    _koopa_install_app \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}
