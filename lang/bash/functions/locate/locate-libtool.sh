#!/usr/bin/env bash

_koopa_locate_libtool() {
    _koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtool' \
        --system-bin-name='libtool' \
        "$@"
}
