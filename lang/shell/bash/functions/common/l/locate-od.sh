#!/usr/bin/env bash

koopa_locate_od() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='god' \
        "$@"
}
