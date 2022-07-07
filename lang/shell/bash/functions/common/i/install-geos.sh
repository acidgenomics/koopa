#!/usr/bin/env bash

koopa_install_geos() {
    koopa_install_app \
        --link-in-bin='bin/geos-config' \
        --name-fancy='GEOS' \
        --name='geos' \
        "$@"
}
