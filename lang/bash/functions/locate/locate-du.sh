#!/usr/bin/env bash

_koopa_locate_du() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdu' \
        --system-bin-name='du' \
        "$@"
}
