#!/usr/bin/env bash

_koopa_linux_install_system_pihole() {
    _koopa_install_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
