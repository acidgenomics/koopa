#!/usr/bin/env bash

_koopa_locate_touch() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gtouch' \
        --system-bin-name='touch' \
        "$@"
}
