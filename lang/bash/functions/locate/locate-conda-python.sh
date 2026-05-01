#!/usr/bin/env bash

_koopa_locate_conda_python() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='python' \
        "$@"
}
