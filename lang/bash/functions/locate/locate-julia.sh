#!/usr/bin/env bash

_koopa_locate_julia() {
    _koopa_locate_app \
        --app-name='julia' \
        --bin-name='julia' \
        "$@"
}
