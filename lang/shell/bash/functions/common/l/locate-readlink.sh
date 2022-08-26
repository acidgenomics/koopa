#!/usr/bin/env bash

koopa_locate_readlink() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='greadlink' \
        "$@" \
}
