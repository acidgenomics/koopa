#!/usr/bin/env bash

koopa_macos_install_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --link-in-bin='bin/R' \
        --link-in-bin='bin/Rscript' \
        --name-fancy='R' \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}
