#!/usr/bin/env bash

_koopa_locate_sed() {
    _koopa_locate_app \
        --app-name='sed' \
        --bin-name='gsed' \
        --system-bin-name='sed' \
        "$@"
}
