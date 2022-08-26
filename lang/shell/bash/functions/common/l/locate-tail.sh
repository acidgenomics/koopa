#!/usr/bin/env bash

koopa_locate_tail() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtail'
        "$@" \
}
