#!/usr/bin/env bash

_koopa_linux_uninstall_system_pihole() {
    _koopa_uninstall_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
