#!/usr/bin/env bash

koopa_linux_install_cellranger() {
    koopa_install_app \
        --link-in-bin='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
