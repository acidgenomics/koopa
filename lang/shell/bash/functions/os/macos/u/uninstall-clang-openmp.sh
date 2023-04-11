#!/usr/bin/env bash

koopa_macos_uninstall_clang_openmp() {
    koopa_uninstall_app \
        --name='clang-openmp' \
        --platform='macos' \
        "$@"
}
