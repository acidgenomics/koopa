#!/usr/bin/env bash

_koopa_locate_stat() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gstat' \
        --system-bin-name='stat' \
        "$@"
}
