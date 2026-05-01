#!/usr/bin/env bash

_koopa_locate_passwd() {
    _koopa_locate_app \
        '/usr/bin/passwd' \
        "$@"
}
