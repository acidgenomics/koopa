#!/usr/bin/env bash

koopa_locate_echo() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gecho' \
        "$@" 
}
