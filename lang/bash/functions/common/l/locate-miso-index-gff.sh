#!/usr/bin/env bash

koopa_locate_miso_index_gff() {
    koopa_locate_app \
        --app-name='misopy' \
        --bin-name='index_gff' \
        "$@"
}
