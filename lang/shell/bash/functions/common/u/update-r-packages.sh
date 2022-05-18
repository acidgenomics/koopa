#!/usr/bin/env bash

koopa_update_r_packages() {
    koopa_update_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}
