#!/usr/bin/env bash

koopa_uninstall_gdal() {
    koopa_uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}
