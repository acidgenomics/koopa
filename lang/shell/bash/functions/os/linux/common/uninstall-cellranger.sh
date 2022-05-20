#!/usr/bin/env bash

koopa_linux_uninstall_cellranger() {
    koopa_uninstall_app \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        --unlink-in-bin='cellranger' \
        "$@"
}
