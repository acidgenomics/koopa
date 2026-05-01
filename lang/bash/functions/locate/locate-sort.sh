#!/usr/bin/env bash

_koopa_locate_sort() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gsort' \
        --system-bin-name='sort' \
        "$@"
}
