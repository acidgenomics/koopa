#!/usr/bin/env bash

koopa_locate_sed() {
    koopa_locate_app \
        --app-name='sed' \
        --bin-name='gsed' \
        --system-bin-name='sed' \
        "$@"
}
