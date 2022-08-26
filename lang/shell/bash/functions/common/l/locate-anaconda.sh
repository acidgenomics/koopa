#!/usr/bin/env bash

koopa_locate_anaconda() {
    koopa_locate_app \
        --app-name='anaconda' \
        --bin-name='conda'
        "$@" \
}
