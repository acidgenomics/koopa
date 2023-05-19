#!/usr/bin/env bash

koopa_macos_locate_diskutil() {
    koopa_locate_app \
        '/usr/sbin/diskutil' \
        "$@"
}
