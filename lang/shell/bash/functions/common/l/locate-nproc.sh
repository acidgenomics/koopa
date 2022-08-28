#!/usr/bin/env bash

koopa_locate_nproc() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnproc' \
        "$@"
}
