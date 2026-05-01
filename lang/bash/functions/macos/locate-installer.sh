#!/usr/bin/env bash

_koopa_macos_locate_installer() {
    _koopa_locate_app \
        '/usr/sbin/installer' \
        "$@"
}
