#!/usr/bin/env bash

koopa_locate_ranlib() {
    koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ranlib' \
        "$@"
}
