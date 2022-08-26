#!/usr/bin/env bash

koopa_locate_head() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ghead' \
        "$@" \
}
