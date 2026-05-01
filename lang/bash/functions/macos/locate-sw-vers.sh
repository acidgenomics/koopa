#!/usr/bin/env bash

_koopa_macos_locate_sw_vers() {
    _koopa_locate_app \
        '/usr/bin/sw_vers' \
        "$@"
}
