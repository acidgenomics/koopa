#!/usr/bin/env bash

_koopa_locate_tr() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtr' \
        --system-bin-name='tr' \
        "$@"
}
