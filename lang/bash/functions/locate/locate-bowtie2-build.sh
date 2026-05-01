#!/usr/bin/env bash

_koopa_locate_bowtie2_build() {
    _koopa_locate_app \
        --app-name='bowtie2' \
        --bin-name='bowtie2-build' \
        "$@"
}
