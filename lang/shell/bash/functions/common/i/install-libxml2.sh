#!/usr/bin/env bash

koopa_install_libxml2() {
    koopa_install_app \
        --link-in-bin='bin/xml2-config' \
        --name='libxml2' \
        "$@"
}
