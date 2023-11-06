#!/usr/bin/env bash

koopa_locate_sam_dump() {
    koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='sam-dump' \
        "$@"
}
