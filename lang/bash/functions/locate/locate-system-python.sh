#!/usr/bin/env bash

_koopa_locate_system_python() {
    _koopa_locate_app \
        --only-system \
        --system-bin-name='python3' \
        "$@"
}
