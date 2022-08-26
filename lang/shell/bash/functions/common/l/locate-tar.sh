#!/usr/bin/env bash

koopa_locate_tar() {
    koopa_locate_app \
        --app-name='tar' \
        --bin-name='gtar' \
        "$@"
}
