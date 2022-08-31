#!/usr/bin/env bash

koopa_locate_rm() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='grm' \
        --system-bin-name='rm' \
        "$@"
}
