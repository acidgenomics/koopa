#!/usr/bin/env bash

_koopa_locate_lzma() {
    _koopa_locate_app \
        --app-name='xz' \
        --bin-name='lzma' \
        "$@"
}
