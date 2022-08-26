#!/usr/bin/env bash

koopa_locate_sort() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gsort'
        "$@" \
}
