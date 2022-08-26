#!/usr/bin/env bash

koopa_locate_julia() {
    koopa_locate_app \
        --app-name='julia' \
        --bin-name='julia'
        "$@" \
}
