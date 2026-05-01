#!/usr/bin/env bash

_koopa_locate_uname() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='guname' \
        --system-bin-name='uname' \
        "$@"
}
