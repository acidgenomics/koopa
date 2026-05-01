#!/usr/bin/env bash

_koopa_locate_hisat2_extract_exons() {
    # Alternatively, can use 'extract_exons.py'.
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_exons.py' \
        "$@"
}
