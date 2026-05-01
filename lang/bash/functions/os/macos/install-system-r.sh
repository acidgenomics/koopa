#!/usr/bin/env bash

_koopa_macos_install_system_r() {
    _koopa_install_app \
        --name='r' \
        --platform='macos' \
        --prefix="$(_koopa_macos_r_prefix)" \
        --system \
        "$@"
}
