#!/usr/bin/env bash

koopa_locate_man() {
    koopa_locate_app \
        --app-name='man-db' \
        --bin-name='gman' \
        "$@"
}
