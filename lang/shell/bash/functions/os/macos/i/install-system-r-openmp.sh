#!/usr/bin/env bash

koopa_macos_install_system_r_openmp() {
    koopa_install_app \
        --name='r-openmp' \
        --no-prefix-check \
        --platform='macos' \
        --system \
        "$@"
}
