#!/usr/bin/env bash

koopa_locate_javac() {
    koopa_locate_app \
        --app-name='temurin' \
        --bin-name='javac' \
        "$@"
}
