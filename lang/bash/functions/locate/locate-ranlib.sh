#!/usr/bin/env bash

_koopa_locate_ranlib() {
    _koopa_locate_app \
        --app-name='binutils' \
        --bin-name='ranlib' \
        "$@"
}
