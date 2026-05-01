#!/usr/bin/env bash

_koopa_locate_luajit() {
    _koopa_locate_app \
        --app-name='luajit' \
        --bin-name='luajit' \
        "$@"
}
