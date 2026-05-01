#!/usr/bin/env bash

_koopa_alpine_locate_apk() {
    _koopa_locate_app \
        '/sbin/apk' \
        "$@"
}
