#!/usr/bin/env bash

koopa_macos_locate_rpcinfo() {
    koopa_locate_app \
        '/usr/sbin/rpcinfo' \
        "$@"
}
