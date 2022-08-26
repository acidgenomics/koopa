#!/usr/bin/env bash

koopa_locate_cat() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcat' \
        "$@" 
}
