#!/usr/bin/env bash

_koopa_macos_locate_dscacheutil() {
    _koopa_locate_app \
        '/usr/bin/dscacheutil' \
        "$@"
}
