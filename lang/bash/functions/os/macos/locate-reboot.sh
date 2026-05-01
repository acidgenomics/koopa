#!/usr/bin/env bash

_koopa_macos_locate_reboot() {
    _koopa_locate_app \
        '/sbin/reboot' \
        "$@"
}
