#!/usr/bin/env bash

koopa_locate_libtool() {
    koopa_locate_app \
        --app-name='libtool' \
        --bin-name='glibtool' \
        --system-bin-name='libtool' \
        "$@"
}
