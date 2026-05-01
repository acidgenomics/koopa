#!/usr/bin/env bash

_koopa_locate_locale() {
    _koopa_locate_app \
        '/usr/bin/locale' \
        "$@"
}
