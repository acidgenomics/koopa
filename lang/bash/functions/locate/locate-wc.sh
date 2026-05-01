#!/usr/bin/env bash

_koopa_locate_wc() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwc' \
        --system-bin-name='wc' \
        "$@"
}
