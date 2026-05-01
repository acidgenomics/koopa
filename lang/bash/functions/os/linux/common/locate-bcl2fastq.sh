#!/usr/bin/env bash

_koopa_linux_locate_bcl2fastq() {
    _koopa_locate_app \
        --app-name='bcl2fastq' \
        --bin-name='bcl2fastq' \
        "$@"
}
