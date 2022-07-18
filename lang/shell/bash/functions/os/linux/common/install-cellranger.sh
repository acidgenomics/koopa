#!/usr/bin/env bash

koopa_linux_install_cellranger() {
    koopa_install_app \
        --link-in-bin='cellranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
