#!/usr/bin/env bash

koopa_locate_gunzip() {
    koopa_locate_app \
        --app-name='gzip' \
        --bin-name='gunzip' \
        "$@"
}
