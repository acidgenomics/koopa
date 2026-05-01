#!/usr/bin/env bash

_koopa_locate_python312() {
    _koopa_locate_app \
        --app-name='python3.12' \
        --bin-name='python3.12' \
        "$@"
}
