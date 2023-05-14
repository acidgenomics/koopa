#!/usr/bin/env bash

koopa_linux_configure_system_lmod() {
    koopa_configure_app \
        --name='lmod' \
        --platform='linux' \
        --system \
        "$@"
}
