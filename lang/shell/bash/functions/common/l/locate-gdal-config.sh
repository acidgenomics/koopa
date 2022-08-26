#!/usr/bin/env bash

koopa_locate_gdal_config() {
    koopa_locate_app \
        --app-name='gdal' \
        --bin-name='gdal-config' \
        "$@" 
}
