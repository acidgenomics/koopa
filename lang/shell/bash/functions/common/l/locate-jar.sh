#!/usr/bin/env bash

koopa_locate_jar() {
    koopa_locate_app \
        --app-name='openjdk' \
        --bin-name='jar' \
        "$@"
}
