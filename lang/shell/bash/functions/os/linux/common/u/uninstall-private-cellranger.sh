#!/usr/bin/env bash

koopa_linux_uninstall_private_cellranger() {
    koopa_uninstall_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
