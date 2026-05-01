#!/usr/bin/env bash

_koopa_locate_libtoolize() {
    _koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtoolize' \
        "$@"
}
