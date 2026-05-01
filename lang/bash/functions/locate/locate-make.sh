#!/usr/bin/env bash

_koopa_locate_make() {
    _koopa_locate_app \
        --app-name='make' \
        --bin-name='gmake' \
        --system-bin-name='make' \
        "$@"
}
