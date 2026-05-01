#!/usr/bin/env bash

_koopa_macos_locate_hdiutil() {
    _koopa_locate_app \
        '/usr/bin/hdiutil' \
        "$@"
}
