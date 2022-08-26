#!/usr/bin/env bash

koopa_locate_stack() {
    koopa_locate_app \
        --app-name='haskell-stack' \
        --bin-name='stack' \
        "$@" 
}
