#!/usr/bin/env bash

_koopa_locate_numfmt() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gnumfmt' \
        --system-bin-name='numfmt' \
        "$@"
}
