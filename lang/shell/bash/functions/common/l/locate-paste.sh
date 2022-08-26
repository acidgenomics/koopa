#!/usr/bin/env bash

koopa_locate_paste() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gpaste'
        "$@" \
}
