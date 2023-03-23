#!/usr/bin/env bash

koopa_macos_uninstall_system_openmp() {
    koopa_uninstall_app \
        --name='openmp' \
        --platform='macos' \
        --system \
        "$@"
}
