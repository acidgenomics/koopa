#!/usr/bin/env bash

_koopa_linux_install_gcc() {
    _koopa_install_app \
        --name='gcc' \
        --platform='linux' \
        "$@"
}
