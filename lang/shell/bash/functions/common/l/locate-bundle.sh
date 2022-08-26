#!/usr/bin/env bash

koopa_locate_bundle() {
    koopa_locate_app \
        --app-name='ruby-packages' \
        --bin-name='bundle' \
        "$@" \
}
