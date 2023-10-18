#!/usr/bin/env bash

koopa_locate_hisat2_build() {
    koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2-build' \
        "$@"
}
