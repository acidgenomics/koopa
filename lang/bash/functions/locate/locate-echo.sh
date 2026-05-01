#!/usr/bin/env bash

_koopa_locate_echo() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gecho' \
        --system-bin-name='echo' \
        "$@"
}
