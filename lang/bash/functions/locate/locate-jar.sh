#!/usr/bin/env bash

_koopa_locate_jar() {
    _koopa_locate_app \
        --app-name='temurin' \
        --bin-name='jar' \
        "$@"
}
