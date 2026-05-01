#!/usr/bin/env bash

_koopa_locate_nproc() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnproc' \
        --system-bin-name='nproc' \
        "$@"
}
