#!/usr/bin/env bash

koopa_uninstall_r() {
    koopa_uninstall_app \
        --name='r' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
    koopa_uninstall_r_packages
    return 0
}
