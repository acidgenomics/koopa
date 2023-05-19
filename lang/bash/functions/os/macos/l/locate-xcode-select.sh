#!/usr/bin/env bash

koopa_macos_locate_xcode_select() {
    koopa_locate_app \
        '/usr/bin/xcode-select' \
        "$@"
}
