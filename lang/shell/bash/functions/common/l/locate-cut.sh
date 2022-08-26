#!/usr/bin/env bash

koopa_locate_cut() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcut' \
        "$@" 
}
