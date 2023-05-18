#!/usr/bin/env bash

koopa_locate_du() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdu' \
        --system-bin-name='du' \
        "$@"
}
