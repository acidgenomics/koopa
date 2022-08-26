#!/usr/bin/env bash

koopa_locate_zcat() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='zcat'
        "$@" \
}
