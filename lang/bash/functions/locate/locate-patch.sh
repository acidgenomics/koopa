#!/usr/bin/env bash

_koopa_locate_patch() {
    _koopa_locate_app \
        --app-name='patch' \
        --bin-name='patch' \
        "$@"
}
