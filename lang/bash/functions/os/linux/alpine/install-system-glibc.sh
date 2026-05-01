#!/usr/bin/env bash

_koopa_alpine_install_system_glibc() {
    _koopa_install_app \
        --name='glibc' \
        --platform='alpine' \
        --system \
        --version='2.30-r0' \
        "$@"
}
