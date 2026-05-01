#!/usr/bin/env bash

_koopa_locate_hostname() {
    _koopa_locate_app \
        '/bin/hostname' \
        "$@"
}
