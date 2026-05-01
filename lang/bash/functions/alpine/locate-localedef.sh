#!/usr/bin/env bash

_koopa_alpine_locate_localedef() {
    _koopa_locate_app \
        '/usr/glibc-compat/bin/localedef' \
        "$@"
}
