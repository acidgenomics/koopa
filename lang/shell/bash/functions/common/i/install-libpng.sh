#!/usr/bin/env bash

koopa_install_libpng() {
    koopa_install_app \
        --link-in-bin='libpng-config' \
        --link-in-bin='libpng16-config' \
        --name='libpng' \
        "$@"
}
