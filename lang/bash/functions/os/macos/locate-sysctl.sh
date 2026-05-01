#!/usr/bin/env bash

_koopa_macos_locate_sysctl() {
    _koopa_locate_app \
        '/usr/sbin/sysctl' \
        "$@"
}
