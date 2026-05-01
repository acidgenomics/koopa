#!/usr/bin/env bash

_koopa_locate_xargs() {
    _koopa_locate_app \
        --app-name='findutils' \
        --bin-name='gxargs' \
        --system-bin-name='xargs' \
        "$@"
}
