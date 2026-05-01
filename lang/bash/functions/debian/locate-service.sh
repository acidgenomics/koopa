#!/usr/bin/env bash

_koopa_debian_locate_service() {
    _koopa_locate_app \
        '/usr/sbin/service' \
        "$@"
}
