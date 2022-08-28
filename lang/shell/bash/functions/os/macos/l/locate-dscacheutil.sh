#!/usr/bin/env bash

koopa_macos_locate_dscacheutil() {
    koopa_locate_app \
        '/usr/bin/dscacheutil' \
        "$@"
}
