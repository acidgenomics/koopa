#!/usr/bin/env bash

_koopa_macos_locate_mount_nfs() {
    _koopa_locate_app \
        '/sbin/mount_nfs' \
        "$@"
}
