#!/usr/bin/env bash

_koopa_locate_python311() {
    _koopa_locate_app \
        --app-name='python3.11' \
        --bin-name='python3.11' \
        "$@"
}
