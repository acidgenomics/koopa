#!/usr/bin/env bash

koopa_locate_cp() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcp'
        "$@" \
}
