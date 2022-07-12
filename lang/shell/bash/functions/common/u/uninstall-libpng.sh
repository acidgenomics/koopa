#!/usr/bin/env bash

koopa_uninstall_libpng() {
    koopa_uninstall_app \
        --name='libpng' \
        --unlink-in-bin='libpng-config' \
        --unlink-in-bin='libpng16-config' \
        "$@"
}
