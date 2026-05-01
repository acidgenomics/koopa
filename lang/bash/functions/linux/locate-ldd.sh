#!/usr/bin/env bash

_koopa_linux_locate_ldd() {
    _koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}
