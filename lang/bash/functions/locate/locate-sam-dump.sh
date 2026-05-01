#!/usr/bin/env bash

_koopa_locate_sam_dump() {
    _koopa_locate_app \
        --app-name='ncbi-sra-tools' \
        --bin-name='sam-dump' \
        "$@"
}
