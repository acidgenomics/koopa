#!/usr/bin/env bash

koopa_locate_ls() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gls' \
        --system-bin-name='ls' \
        "$@"
}
