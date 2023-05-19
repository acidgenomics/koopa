#!/usr/bin/env bash

koopa_locate_patch() {
    koopa_locate_app \
        --app-name='patch' \
        --bin-name='patch' \
        "$@"
}
