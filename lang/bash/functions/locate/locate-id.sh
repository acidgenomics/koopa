#!/usr/bin/env bash

_koopa_locate_id() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gid' \
        --system-bin-name='id' \
        "$@"
}
