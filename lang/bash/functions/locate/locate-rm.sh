#!/usr/bin/env bash

_koopa_locate_rm() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grm' \
        --system-bin-name='rm' \
        "$@"
}
