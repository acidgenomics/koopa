#!/usr/bin/env bash

koopa_macos_uninstall_r_binary() {
    koopa_uninstall_app \
        --name='r' \
        --platform='macos' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}
