#!/usr/bin/env bash

koopa_locate_geos_config() {
    koopa_locate_app \
        --app-name='geos' \
        --bin-name='geos-config'
        "$@" \
}
