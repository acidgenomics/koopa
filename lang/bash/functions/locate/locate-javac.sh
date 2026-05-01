#!/usr/bin/env bash

_koopa_locate_javac() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='javac' \
        "$@"
}
