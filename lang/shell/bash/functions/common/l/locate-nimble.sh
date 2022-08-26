#!/usr/bin/env bash

koopa_locate_nimble() {
    koopa_locate_app \
        --app-name='nim' \
        --bin-name='nimble'
        "$@" \
}
