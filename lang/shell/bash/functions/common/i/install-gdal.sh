#!/usr/bin/env bash

koopa_install_gdal() {
    koopa_install_app \
        --link-in-bin='bin/gdal-config' \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}
