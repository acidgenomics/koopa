#!/usr/bin/env bash

_koopa_locate_date() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdate' \
        --system-bin-name='date' \
        "$@"
}
