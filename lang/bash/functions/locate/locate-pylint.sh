#!/usr/bin/env bash

_koopa_locate_pylint() {
    _koopa_locate_app \
        --app-name='pylint' \
        --bin-name='pylint' \
        "$@"
}
