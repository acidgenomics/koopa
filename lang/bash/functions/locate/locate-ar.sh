#!/usr/bin/env bash

_koopa_locate_ar() {
    _koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ar' \
        "$@"
}
