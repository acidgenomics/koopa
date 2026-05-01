#!/usr/bin/env bash

_koopa_linux_locate_useradd() {
    _koopa_locate_app \
        '/usr/sbin/useradd' \
        "$@"
}
