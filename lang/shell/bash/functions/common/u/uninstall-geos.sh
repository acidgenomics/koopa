#!/usr/bin/env bash

koopa_uninstall_geos() {
    koopa_uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        --unlink-in-bin='geos-config' \
        "$@"
}
