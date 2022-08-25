#!/usr/bin/env bash

koopa_linux_install_cellranger() {
    koopa_install_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
