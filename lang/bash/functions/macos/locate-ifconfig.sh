#!/usr/bin/env bash

_koopa_macos_locate_ifconfig() {
    _koopa_locate_app \
        '/sbin/ifconfig' \
        "$@"
}
