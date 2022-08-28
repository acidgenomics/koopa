#!/usr/bin/env bash

koopa_locate_java() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='java' \
        "$@"
}
