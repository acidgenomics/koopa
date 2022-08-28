#!/usr/bin/env bash

koopa_locate_javac() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='javac' \
        "$@"
}
