#!/usr/bin/env bash

_koopa_locate_env() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='genv' \
        --system-bin-name='env' \
        "$@"
}
