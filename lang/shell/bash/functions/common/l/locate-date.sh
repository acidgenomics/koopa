#!/usr/bin/env bash

koopa_locate_date() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdate' \
        "$@" \
}
