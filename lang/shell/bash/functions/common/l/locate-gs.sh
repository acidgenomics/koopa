#!/usr/bin/env bash

koopa_locate_gs() {
    koopa_locate_app \
        --app-name='ghostscript' \
        --bin-name='gs' \
        "$@" \
}
