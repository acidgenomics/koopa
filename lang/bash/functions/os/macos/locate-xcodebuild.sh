#!/usr/bin/env bash

_koopa_macos_locate_xcodebuild() {
    _koopa_locate_app \
        '/usr/bin/xcodebuild' \
        "$@"
}
