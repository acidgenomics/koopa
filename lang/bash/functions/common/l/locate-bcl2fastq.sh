#!/usr/bin/env bash

koopa_locate_bcl2fastq() {
    koopa_locate_app \
        --app-name='bcl2fastq' \
        --bin-name='bcl2fastq' \
        "$@"
}
