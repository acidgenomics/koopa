#!/usr/bin/env bash

_koopa_debian_install_system_r() {
    _koopa_install_app \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}
