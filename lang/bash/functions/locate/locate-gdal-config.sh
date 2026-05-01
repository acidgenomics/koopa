#!/usr/bin/env bash

_koopa_locate_gdal_config() {
    _koopa_locate_app \
        --app-name='gdal' \
        --bin-name='gdal-config' \
        "$@"
}
