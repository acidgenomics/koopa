#!/usr/bin/env bash

koopa_uninstall_xorg_libice() {
    koopa_uninstall_app \
        --name='xorg-libice' \
        "$@"
}
