#!/usr/bin/env bash

koopa_linux_configure_system_sshd() {
    koopa_configure_app \
        --name='sshd' \
        --platform='linux' \
        --system \
        "$@"
}
