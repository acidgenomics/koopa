#!/usr/bin/env bash

koopa_debian_uninstall_r_binary() {
    koopa_uninstall_app \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}
