#!/usr/bin/env bash

_koopa_locate_rsync() {
    _koopa_locate_app \
        --app-name='rsync' \
        --bin-name='rsync' \
        "$@"
}
