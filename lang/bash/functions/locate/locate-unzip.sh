#!/usr/bin/env bash

_koopa_locate_unzip() {
    _koopa_locate_app \
        --app-name='unzip' \
        --bin-name='unzip' \
        --system-bin-name='unzip' \
        "$@"
}
