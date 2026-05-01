#!/usr/bin/env bash

_koopa_locate_pytest() {
    _koopa_locate_app \
        --app-name='pytest' \
        --bin-name='pytest' \
        "$@"
}
