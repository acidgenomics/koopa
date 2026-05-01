#!/usr/bin/env bash

_koopa_locate_rsem_prepare_reference() {
    _koopa_locate_app \
        --app-name='rsem' \
        --bin-name='rsem-prepare-reference' \
        "$@"
}
