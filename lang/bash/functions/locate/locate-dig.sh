#!/usr/bin/env bash

_koopa_locate_dig() {
    _koopa_locate_app \
        --app-name='bind' \
        --bin-name='dig' \
        "$@"
}
