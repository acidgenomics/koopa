#!/usr/bin/env bash

_koopa_locate_rg() {
    _koopa_locate_app \
        --app-name='ripgrep' \
        --bin-name='rg' \
        "$@"
}
