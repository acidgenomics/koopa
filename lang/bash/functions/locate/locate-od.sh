#!/usr/bin/env bash

_koopa_locate_od() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='god' \
        --system-bin-name='od' \
        "$@"
}
