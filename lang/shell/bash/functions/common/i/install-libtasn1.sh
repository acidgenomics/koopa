#!/usr/bin/env bash

koopa_install_libtasn1() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='libtasn1' \
        "$@"
}
