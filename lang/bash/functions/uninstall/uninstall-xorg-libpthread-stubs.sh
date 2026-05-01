#!/usr/bin/env bash

_koopa_uninstall_xorg_libpthread_stubs() {
    _koopa_uninstall_app \
        --name='xorg-libpthread-stubs' \
        "$@"
}
