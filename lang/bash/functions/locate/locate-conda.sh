#!/usr/bin/env bash

_koopa_locate_conda() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='conda' \
        "$@"
}
