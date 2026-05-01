#!/usr/bin/env bash

_koopa_locate_tac() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtac' \
        --system-bin-name='tac' \
        "$@"
}
