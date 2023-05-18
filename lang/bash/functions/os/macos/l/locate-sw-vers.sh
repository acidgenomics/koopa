#!/usr/bin/env bash

koopa_macos_locate_sw_vers() {
    koopa_locate_app \
        '/usr/bin/sw_vers' \
        "$@"
}
