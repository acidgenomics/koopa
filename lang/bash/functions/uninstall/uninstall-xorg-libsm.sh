#!/usr/bin/env bash

_koopa_uninstall_xorg_libsm() {
    _koopa_uninstall_app \
        --name='xorg-libsm' \
        "$@"
}
