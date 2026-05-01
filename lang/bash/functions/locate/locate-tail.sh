#!/usr/bin/env bash

_koopa_locate_tail() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtail' \
        --system-bin-name='tail' \
        "$@"
}
