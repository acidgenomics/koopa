#!/usr/bin/env bash

_koopa_locate_rustc() {
    _koopa_locate_app \
        --app-name='rust' \
        --bin-name='rustc' \
        "$@"
}
