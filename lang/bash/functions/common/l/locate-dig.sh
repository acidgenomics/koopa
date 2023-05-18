#!/usr/bin/env bash

koopa_locate_dig() {
    koopa_locate_app \
        --app-name='bind' \
        --bin-name='dig' \
        "$@"
}
