#!/usr/bin/env bash

koopa_locate_mktemp() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmktemp' \
        --system-bin-name='mktemp' \
        "$@"
}
