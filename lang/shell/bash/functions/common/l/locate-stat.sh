#!/usr/bin/env bash

koopa_locate_stat() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gstat' \
        "$@" \
}
