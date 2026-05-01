#!/usr/bin/env bash

_koopa_locate_pyenv() {
    _koopa_locate_app \
        --app-name='pyenv' \
        --bin-name='pyenv' \
        "$@"
}
