#!/usr/bin/env bash

_koopa_locate_ln() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gln' \
        --system-bin-name='ln' \
        "$@"
}
