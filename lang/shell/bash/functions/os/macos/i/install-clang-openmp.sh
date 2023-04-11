#!/usr/bin/env bash

koopa_macos_install_clang_openmp() {
    koopa_install_app \
        --name='clang-openmp' \
        --platform='macos' \
        "$@"
}
