#!/usr/bin/env bash

koopa_locate_rg() {
    koopa_locate_app \
        --app-name='ripgrep' \
        --bin-name='rg' \
        "$@"
}
