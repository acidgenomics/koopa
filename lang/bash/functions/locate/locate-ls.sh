#!/usr/bin/env bash

_koopa_locate_ls() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gls' \
        --system-bin-name='ls' \
        "$@"
}
