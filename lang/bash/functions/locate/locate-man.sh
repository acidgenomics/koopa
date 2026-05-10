#!/usr/bin/env bash

_koopa_locate_man() {
    _koopa_locate_app \
        --app-name='man-db' \
        --bin-name='gman' \
        --system-bin-name='man' \
        "$@"
}
