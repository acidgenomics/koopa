#!/usr/bin/env bash

_koopa_locate_mv() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmv' \
        --system-bin-name='mv' \
        "$@"
}
