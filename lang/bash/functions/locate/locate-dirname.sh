#!/usr/bin/env bash

_koopa_locate_dirname() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdirname' \
        --system-bin-name='dirname' \
        "$@"
}
