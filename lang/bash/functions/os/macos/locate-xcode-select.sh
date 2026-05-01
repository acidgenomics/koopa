#!/usr/bin/env bash

_koopa_macos_locate_xcode_select() {
    _koopa_locate_app \
        '/usr/bin/xcode-select' \
        "$@"
}
