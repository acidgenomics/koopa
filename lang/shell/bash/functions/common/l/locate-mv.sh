#!/usr/bin/env bash

koopa_locate_mv() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmv' \
        --system-bin-name='mv' \
        "$@"
}
