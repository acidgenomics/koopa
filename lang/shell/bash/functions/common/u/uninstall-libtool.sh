#!/usr/bin/env bash

koopa_uninstall_libtool() {
    koopa_uninstall_app \
        --name='libtool' \
        --unlink-in-bin='glibtool' \
        --unlink-in-bin='glibtoolize' \
        --unlink-in-bin='libtool' \
        --unlink-in-bin='libtoolize' \
        "$@"
}
