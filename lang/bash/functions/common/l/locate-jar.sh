#!/usr/bin/env bash

koopa_locate_jar() {
    koopa_locate_app \
        --app-name='temurin' \
        --bin-name='jar' \
        "$@"
}
