#!/usr/bin/env bash

koopa_locate_libtoolize() {
    koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtoolize' \
        "$@"
}
