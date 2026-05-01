#!/usr/bin/env bash

_koopa_locate_geos_config() {
    _koopa_locate_app \
        --app-name='geos' \
        --bin-name='geos-config' \
        "$@"
}
