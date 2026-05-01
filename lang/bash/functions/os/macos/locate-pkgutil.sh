#!/usr/bin/env bash

_koopa_macos_locate_pkgutil() {
    _koopa_locate_app \
        '/usr/sbin/pkgutil' \
        "$@"
}
