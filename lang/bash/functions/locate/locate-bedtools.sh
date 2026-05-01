#!/usr/bin/env bash

_koopa_locate_bedtools() {
    _koopa_locate_app \
        --app-name='bedtools' \
        --bin-name='bedtools' \
        "$@"
}
