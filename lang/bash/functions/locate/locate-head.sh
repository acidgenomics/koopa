#!/usr/bin/env bash

_koopa_locate_head() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ghead' \
        --system-bin-name='head' \
        "$@"
}
