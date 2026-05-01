#!/usr/bin/env bash

_koopa_locate_mamba() {
    _koopa_locate_app \
        --app-name='conda' \
        --bin-name='mamba' \
        "$@"
}
