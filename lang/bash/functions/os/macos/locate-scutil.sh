#!/usr/bin/env bash

_koopa_macos_locate_scutil() {
    _koopa_locate_app \
        '/usr/sbin/scutil' \
        "$@"
}
