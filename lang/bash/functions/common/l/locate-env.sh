#!/usr/bin/env bash

koopa_locate_env() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='genv' \
        --system-bin-name='env' \
        "$@"
}
