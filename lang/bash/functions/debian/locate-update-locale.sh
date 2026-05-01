#!/usr/bin/env bash

_koopa_debian_locate_update_locale() {
    _koopa_locate_app \
        '/usr/sbin/update-locale' \
        "$@"
}
