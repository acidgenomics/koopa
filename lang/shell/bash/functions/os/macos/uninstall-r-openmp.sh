#!/usr/bin/env bash

koopa_macos_uninstall_r_openmp() {
    koopa_uninstall_app \
        --name-fancy='R OpenMP' \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
