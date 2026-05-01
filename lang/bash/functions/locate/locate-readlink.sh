#!/usr/bin/env bash

_koopa_locate_readlink() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='greadlink' \
        --system-bin-name='readlink' \
        "$@"
}
