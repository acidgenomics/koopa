#!/usr/bin/env bash

_koopa_locate_tar() {
    _koopa_locate_app \
        --app-name='tar' \
        --bin-name='gtar' \
        --system-bin-name='tar' \
        "$@"
}
