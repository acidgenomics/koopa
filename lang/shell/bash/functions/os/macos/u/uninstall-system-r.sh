#!/usr/bin/env bash

koopa_macos_uninstall_system_r() {
    koopa_uninstall_app \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
    koopa_uninstall_r_packages
}
