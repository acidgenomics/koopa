#!/usr/bin/env bash

_koopa_locate_hisat2_build() {
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2-build' \
        "$@"
}
