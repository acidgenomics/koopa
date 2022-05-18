#!/usr/bin/env bash

koopa_uninstall_r_packages() {
    koopa_uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}
