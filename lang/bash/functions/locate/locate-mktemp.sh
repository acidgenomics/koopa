#!/usr/bin/env bash

_koopa_locate_mktemp() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmktemp' \
        --system-bin-name='mktemp' \
        "$@"
}
