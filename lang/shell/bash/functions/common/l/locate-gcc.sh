#!/usr/bin/env bash

koopa_locate_gcc() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gcc' \
        "$@"
}
