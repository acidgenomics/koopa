#!/usr/bin/env bash

_koopa_macos_locate_xcrun() {
    _koopa_locate_app \
        '/usr/bin/xcrun' \
        "$@"
}
