#!/usr/bin/env bash

koopa_locate_pyenv() {
    koopa_locate_app \
        --app-name='pyenv' \
        --bin-name='pyenv' \
        "$@" \
}
