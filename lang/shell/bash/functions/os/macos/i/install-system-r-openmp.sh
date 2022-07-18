#!/usr/bin/env bash

koopa_macos_install_r_openmp() {
    koopa_install_app \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
