#!/usr/bin/env bash

koopa_locate_java() {
    koopa_locate_app \
        --app-name='temurin' \
        --bin-name='java' \
        "$@"
}
