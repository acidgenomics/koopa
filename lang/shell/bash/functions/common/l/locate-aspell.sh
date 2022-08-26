#!/usr/bin/env bash

koopa_locate_aspell() {
    koopa_locate_app \
        --app-name='aspell' \
        --bin-name='aspell'
        "$@" \
}
