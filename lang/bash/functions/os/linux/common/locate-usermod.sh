#!/usr/bin/env bash

_koopa_linux_locate_usermod() {
    _koopa_locate_app \
        '/usr/sbin/usermod' \
        "$@"
}
