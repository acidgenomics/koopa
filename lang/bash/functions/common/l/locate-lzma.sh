#!/usr/bin/env bash

koopa_locate_lzma() {
    koopa_locate_app \
        --app-name='xz' \
        --bin-name='lzma' \
        "$@"
}
