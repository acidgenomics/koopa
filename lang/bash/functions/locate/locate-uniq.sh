#!/usr/bin/env bash

_koopa_locate_uniq() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guniq' \
        --system-bin-name='uniq' \
        "$@"
}
