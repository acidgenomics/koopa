#!/usr/bin/env bash

koopa_macos_locate_reboot() {
    koopa_locate_app \
        '/sbin/reboot' \
        "$@"
}
