#!/usr/bin/env bash

_koopa_locate_gcc() {
    _koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gcc' \
        "$@"
}
