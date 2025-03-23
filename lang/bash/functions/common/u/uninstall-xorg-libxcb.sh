#!/usr/bin/env bash

koopa_uninstall_xorg_libxcb() {
    koopa_uninstall_app \
        --name='xorg-libxcb' \
        "$@"
}
