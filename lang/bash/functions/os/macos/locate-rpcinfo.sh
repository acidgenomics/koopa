#!/usr/bin/env bash

_koopa_macos_locate_rpcinfo() {
    _koopa_locate_app \
        '/usr/sbin/rpcinfo' \
        "$@"
}
