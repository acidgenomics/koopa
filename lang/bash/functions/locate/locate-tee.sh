#!/usr/bin/env bash

_koopa_locate_tee() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtee' \
        --system-bin-name='tee' \
        "$@"
}
