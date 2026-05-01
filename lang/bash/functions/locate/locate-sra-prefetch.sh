#!/usr/bin/env bash

_koopa_locate_sra_prefetch() {
    _koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='prefetch' \
        "$@"
}
