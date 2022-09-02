#!/usr/bin/env bash

koopa_macos_locate_systemsetup() {
    koopa_locate_app \
        '/usr/sbin/systemsetup' \
        "$@"
}
