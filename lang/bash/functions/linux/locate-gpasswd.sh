#!/usr/bin/env bash

_koopa_linux_locate_gpasswd() {
    _koopa_locate_app \
        '/usr/bin/gpasswd' \
        "$@"
}
