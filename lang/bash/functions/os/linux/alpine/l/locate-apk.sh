#!/usr/bin/env bash

koopa_alpine_locate_apk() {
    koopa_locate_app \
        '/sbin/apk' \
        "$@"
}
