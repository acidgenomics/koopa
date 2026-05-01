#!/usr/bin/env bash

_koopa_locate_miso_index_gff() {
    _koopa_locate_app \
        --app-name='misopy' \
        --bin-name='index_gff' \
        "$@"
}
