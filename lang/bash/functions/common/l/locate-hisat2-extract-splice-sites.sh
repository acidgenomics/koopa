#!/usr/bin/env bash

koopa_locate_hisat2_extract_splice_sites() {
    # Alternatively, can use 'extract_splice_sites.py'.
    koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_splice_sites.py' \
        "$@"
}
