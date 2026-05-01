#!/usr/bin/env bash

_koopa_linux_uninstall_private_cellranger() {
    _koopa_uninstall_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
