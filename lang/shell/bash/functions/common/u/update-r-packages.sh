#!/usr/bin/env bash

koopa_update_r_packages() {
    koopa_update_app \
        --name='r-packages' \
        --no-prefix-check \
        "$@"
}
