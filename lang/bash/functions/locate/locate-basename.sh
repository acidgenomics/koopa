#!/usr/bin/env bash

_koopa_locate_basename() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gbasename' \
        --system-bin-name='basename' \
        "$@"
}
