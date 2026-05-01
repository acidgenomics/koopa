#!/usr/bin/env bash

_koopa_locate_msgmerge() {
    _koopa_locate_app \
        --app-name='gettext' \
        --bin-name='msgmerge' \
        "$@"
}
