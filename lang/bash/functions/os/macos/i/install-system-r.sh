#!/usr/bin/env bash

koopa_macos_install_system_r() {
    koopa_install_app \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}
