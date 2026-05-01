#!/usr/bin/env bash

_koopa_locate_install() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ginstall' \
        "$@"
}
