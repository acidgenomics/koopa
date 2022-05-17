#!/usr/bin/env bash

koopa_install_gdal() {
    koopa_install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}
