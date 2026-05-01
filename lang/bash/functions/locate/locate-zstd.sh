#!/usr/bin/env bash

_koopa_locate_zstd() {
    _koopa_locate_app \
        --app-name='zstd' \
        --bin-name='zstd' \
        "$@"
}
