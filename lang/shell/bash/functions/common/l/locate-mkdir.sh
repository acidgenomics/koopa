#!/usr/bin/env bash

koopa_locate_mkdir() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gmkdir' \
        "$@"
}
