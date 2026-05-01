#!/usr/bin/env bash

_koopa_locate_git() {
    _koopa_locate_app \
        --app-name='git' \
        --bin-name='git' \
        "$@"
}
