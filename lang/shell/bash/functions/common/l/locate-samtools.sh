#!/usr/bin/env bash

koopa_locate_samtools() {
    koopa_locate_app \
        --app-name='samtools' \
        --bin-name='samtools'
        "$@" \
}
