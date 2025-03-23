#!/usr/bin/env bash

koopa_locate_fasterq_dump() {
    koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='fasterq-dump' \
        "$@"
}
