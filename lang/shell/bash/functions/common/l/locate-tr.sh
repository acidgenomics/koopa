#!/usr/bin/env bash

koopa_locate_tr() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtr'
        "$@" \
}
