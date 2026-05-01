#!/usr/bin/env bash

_koopa_locate_luac() {
    _koopa_locate_app \
        --app-name='lua' \
        --bin-name='luac' \
        "$@"
}
