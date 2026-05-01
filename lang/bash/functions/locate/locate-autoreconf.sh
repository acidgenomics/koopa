#!/usr/bin/env bash

_koopa_locate_autoreconf() {
    _koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoreconf' \
        "$@"
}
