#!/usr/bin/env bash

koopa_uninstall_xorg_libsm() {
    koopa_uninstall_app \
        --name='xorg-libsm' \
        "$@"
}
