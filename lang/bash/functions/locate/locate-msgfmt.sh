#!/usr/bin/env bash

_koopa_locate_msgfmt() {
    _koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgfmt' \
        "$@"
}
