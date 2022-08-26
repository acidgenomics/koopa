#!/usr/bin/env bash

koopa_locate_fd() {
    koopa_locate_app \
        --app-name='fd-find' \
        --bin-name='fd' \
        "$@"
}
