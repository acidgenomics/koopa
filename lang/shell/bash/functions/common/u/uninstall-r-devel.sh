#!/usr/bin/env bash

koopa_uninstall_r_devel() {
    koopa_uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --unlink-in-bin='R-devel' \
        "$@"
}
