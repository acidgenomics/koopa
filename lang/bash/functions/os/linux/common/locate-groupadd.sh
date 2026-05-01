#!/usr/bin/env bash

_koopa_linux_locate_groupadd() {
    _koopa_locate_app \
        '/usr/sbin/groupadd' \
        "$@"
}
