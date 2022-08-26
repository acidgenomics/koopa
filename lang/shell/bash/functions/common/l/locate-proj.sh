#!/usr/bin/env bash

koopa_locate_proj() {
    koopa_locate_app \
        --app-name='proj' \
        --bin-name='proj'
        "$@" \
}
