#!/usr/bin/env bash

_koopa_locate_java() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='java' \
        "$@"
}
