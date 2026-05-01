#!/usr/bin/env bash

_koopa_locate_cargo() {
    _koopa_locate_app \
        --app-name='rust' \
        --bin-name='cargo' \
        "$@"
}
