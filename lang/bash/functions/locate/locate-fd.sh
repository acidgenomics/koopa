#!/usr/bin/env bash

_koopa_locate_fd() {
    _koopa_locate_app \
        --app-name='fd-find' \
        --bin-name='fd' \
        "$@"
}
