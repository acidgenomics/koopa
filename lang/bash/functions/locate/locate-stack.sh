#!/usr/bin/env bash

_koopa_locate_stack() {
    _koopa_locate_app \
        --app-name='haskell-stack' \
        --bin-name='stack' \
        "$@"
}
