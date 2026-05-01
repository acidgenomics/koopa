#!/usr/bin/env bash

_koopa_locate_hisat2_extract_splice_sites() {
    # Alternatively, can use 'extract_splice_sites.py'.
    _koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_splice_sites.py' \
        "$@"
}
