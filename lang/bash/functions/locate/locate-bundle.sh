#!/usr/bin/env bash

_koopa_locate_bundle() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='bundle' \
        "$@"
}
