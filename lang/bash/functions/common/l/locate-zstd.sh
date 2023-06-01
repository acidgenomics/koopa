#!/usr/bin/env bash

koopa_locate_zstd() {
    koopa_locate_app \
        --app-name='zstd' \
        --bin-name='zstd' \
        "$@"
}
