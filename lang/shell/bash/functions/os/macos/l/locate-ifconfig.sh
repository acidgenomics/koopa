#!/usr/bin/env bash

koopa_macos_locate_ifconfig() {
    koopa_locate_app \
        '/sbin/ifconfig' \
        "$@"
}
