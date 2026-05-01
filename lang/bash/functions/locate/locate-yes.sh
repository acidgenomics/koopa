#!/usr/bin/env bash

_koopa_locate_yes() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gyes' \
        --system-bin-name='yes' \
        "$@"
}
