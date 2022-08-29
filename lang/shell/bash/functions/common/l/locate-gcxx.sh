#!/usr/bin/env bash

koopa_locate_gcxx() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='g++' \
        "$@"
}
