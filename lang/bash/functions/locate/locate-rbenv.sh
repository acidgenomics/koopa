#!/usr/bin/env bash

_koopa_locate_rbenv() {
    _koopa_locate_app \
        --app-name='rbenv' \
        --bin-name='rbenv' \
        "$@"
}
