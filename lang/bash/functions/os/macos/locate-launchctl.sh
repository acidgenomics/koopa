#!/usr/bin/env bash

_koopa_macos_locate_launchctl() {
    _koopa_locate_app \
        '/bin/launchctl' \
        "$@"
}
