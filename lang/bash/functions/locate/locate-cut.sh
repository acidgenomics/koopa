#!/usr/bin/env bash

_koopa_locate_cut() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcut' \
        --system-bin-name='cut' \
        "$@"
}
