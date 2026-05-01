#!/usr/bin/env bash

_koopa_locate_cp() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gcp' \
        --system-bin-name='cp' \
        "$@"
}
