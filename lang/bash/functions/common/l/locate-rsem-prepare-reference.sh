#!/usr/bin/env bash

koopa_locate_rsem_prepare_reference() {
    koopa_locate_app \
        --app-name='rsem' \
        --bin-name='rsem-prepare-reference' \
        "$@"
}
