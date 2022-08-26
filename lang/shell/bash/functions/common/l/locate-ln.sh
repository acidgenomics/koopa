#!/usr/bin/env bash

koopa_locate_ln() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gln' \
        "$@" \
}
