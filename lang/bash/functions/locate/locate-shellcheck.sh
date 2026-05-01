#!/usr/bin/env bash

_koopa_locate_shellcheck() {
    _koopa_locate_app \
        --app-name='shellcheck' \
        --bin-name='shellcheck' \
        "$@"
}
