#!/usr/bin/env bash

koopa_uninstall_gdal() {
    koopa_uninstall_app \
        --name='gdal' \
        --unlink-in-bin='gdal-config' \
        "$@"
}
