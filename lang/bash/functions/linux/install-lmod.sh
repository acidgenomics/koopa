#!/usr/bin/env bash

_koopa_linux_install_lmod() {
    _koopa_install_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}
