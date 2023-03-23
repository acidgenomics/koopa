#!/usr/bin/env bash

koopa_macos_install_system_openmp() {
    koopa_install_app \
        --name='openmp' \
        --no-prefix-check \
        --platform='macos' \
        --system \
        "$@"
}
