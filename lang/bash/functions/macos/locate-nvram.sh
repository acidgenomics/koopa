#!/usr/bin/env bash

_koopa_macos_locate_nvram() {
    _koopa_locate_app \
        '/usr/sbin/nvram' \
        "$@"
}
