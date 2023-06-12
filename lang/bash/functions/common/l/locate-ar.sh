#!/usr/bin/env bash

koopa_locate_ar() {
    koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ar' \
        "$@"
}
