#!/usr/bin/env bash

koopa_macos_locate_nvram() {
    koopa_locate_app \
        '/usr/sbin/nvram' \
        "$@"
}
