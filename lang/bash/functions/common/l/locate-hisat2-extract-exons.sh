#!/usr/bin/env bash

koopa_locate_hisat2_extract_exons() {
    # Alternatively, can use 'extract_exons.py'.
    koopa_locate_app \
        --app-name='hisat2' \
        --bin-name='hisat2_extract_exons.py' \
        "$@"
}
