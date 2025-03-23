#!/usr/bin/env bash

koopa_locate_pytest() {
    koopa_locate_app \
        --app-name='pytest' \
        --bin-name='pytest' \
        "$@"
}
