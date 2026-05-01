#!/usr/bin/env bash

_koopa_locate_gs() {
    _koopa_locate_app \
        --app-name='ghostscript' \
        --bin-name='gs' \
        "$@"
}
