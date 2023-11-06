#!/usr/bin/env bash

koopa_locate_sra_prefetch() {
    koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='prefetch' \
        "$@"
}
