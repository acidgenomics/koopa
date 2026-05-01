#!/usr/bin/env bash

_koopa_locate_rscript() {
    _koopa_locate_app \
        --app-name='r' \
        --bin-name='Rscript' \
        "$@"
}
