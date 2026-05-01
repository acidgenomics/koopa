#!/usr/bin/env bash

_koopa_locate_ruby() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='ruby' \
        "$@"
}
