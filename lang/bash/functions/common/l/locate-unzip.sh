#!/usr/bin/env bash

koopa_locate_unzip() {
    koopa_locate_app \
        --app-name='unzip' \
        --bin-name='unzip' \
        --system-bin-name='unzip' \
        "$@"
}
