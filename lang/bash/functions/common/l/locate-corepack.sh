#!/usr/bin/env bash

koopa_locate_corepack() {
    koopa_locate_app \
        --app-name='node' \
        --bin-name='corepack' \
        "$@"
}
