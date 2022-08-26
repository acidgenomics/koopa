#!/usr/bin/env bash

koopa_locate_wc() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwc' \
        "$@" 
}
