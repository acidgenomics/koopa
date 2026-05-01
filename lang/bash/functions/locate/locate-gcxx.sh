#!/usr/bin/env bash

_koopa_locate_gcxx() {
    _koopa_locate_app \
        --app-name='gcc' \
        --bin-name='g++' \
        "$@"
}
