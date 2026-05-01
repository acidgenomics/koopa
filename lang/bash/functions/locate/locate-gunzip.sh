#!/usr/bin/env bash

_koopa_locate_gunzip() {
    _koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gunzip' \
        "$@"
}
