#!/usr/bin/env bash

koopa_locate_numfmt() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnumfmt'
        "$@" \
}
