#!/usr/bin/env bash

_koopa_linux_configure_system_sshd() {
    _koopa_configure_app \
        --name='sshd' \
        --platform='linux' \
        --system \
        "$@"
}
