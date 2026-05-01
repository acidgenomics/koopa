#!/usr/bin/env bash

_koopa_locate_realpath() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grealpath' \
        --system-bin-name='realpath' \
        "$@"
}
