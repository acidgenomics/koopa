#!/usr/bin/env bash

_koopa_locate_cat() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcat' \
        --system-bin-name='cat' \
        "$@"
}
