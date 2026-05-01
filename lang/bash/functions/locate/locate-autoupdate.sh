#!/usr/bin/env bash

_koopa_locate_autoupdate() {
    _koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoupdate' \
        "$@"
}
