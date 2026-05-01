#!/usr/bin/env bash

_koopa_locate_gem() {
    _koopa_locate_app \
        --app-name='ruby' \
        --bin-name='gem' \
        "$@"
}
