#!/usr/bin/env bash

_koopa_locate_python310() {
    _koopa_locate_app \
        --app-name='python3.10' \
        --bin-name='python3.10' \
        "$@"
}
