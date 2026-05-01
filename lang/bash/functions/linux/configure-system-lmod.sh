#!/usr/bin/env bash

_koopa_linux_configure_system_lmod() {
    _koopa_configure_app \
        --name='lmod' \
        --platform='linux' \
        --system \
        "$@"
}
