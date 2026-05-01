#!/usr/bin/env bash

_koopa_locate_ctest() {
    _koopa_locate_app \
        --app-name='cmake' \
        --bin-name='ctest' \
        "$@"
}
