#!/usr/bin/env bash

koopa_uninstall_xorg_libxext() {
    koopa_uninstall_app \
        --name='xorg-libxext' \
        "$@"
}
