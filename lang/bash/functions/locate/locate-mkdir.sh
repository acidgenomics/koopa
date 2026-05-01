#!/usr/bin/env bash

_koopa_locate_mkdir() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmkdir' \
        --system-bin-name='mkdir' \
        "$@"
}
