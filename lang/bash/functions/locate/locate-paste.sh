#!/usr/bin/env bash

_koopa_locate_paste() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gpaste' \
        --system-bin-name='paste' \
        "$@"
}
