#!/usr/bin/env bash

_koopa_locate_localedef() {
    if _koopa_is_alpine
    then
        _koopa_alpine_locate_localedef "$@"
    else
        _koopa_locate_app \
            '/usr/bin/localedef' \
            "$@"
    fi
}
