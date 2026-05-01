#!/usr/bin/env bash

_koopa_locate_samtools() {
    _koopa_locate_app \
        --app-name='samtools' \
        --bin-name='samtools' \
        "$@"
}
