#!/usr/bin/env bash

koopa_macos_install_system_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --link-in-bin='R' \
        --link-in-bin='Rscript' \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}
