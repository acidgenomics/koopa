#!/usr/bin/env bash

_koopa_locate_corepack() {
    _koopa_locate_app \
        --app-name='node' \
        --bin-name='corepack' \
        "$@"
}
