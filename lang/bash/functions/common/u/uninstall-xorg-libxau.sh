#!/usr/bin/env bash

koopa_uninstall_xorg_libxau() {
    koopa_uninstall_app \
        --name='xorg-libxau' \
        "$@"
}
