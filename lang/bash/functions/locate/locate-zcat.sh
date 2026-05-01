#!/usr/bin/env bash

_koopa_locate_zcat() {
    _koopa_locate_app \
        --app-name='gzip' \
        --bin-name='zcat' \
        "$@"
}
