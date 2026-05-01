#!/usr/bin/env bash

_koopa_macos_locate_systemsetup() {
    _koopa_locate_app \
        '/usr/sbin/systemsetup' \
        "$@"
}
