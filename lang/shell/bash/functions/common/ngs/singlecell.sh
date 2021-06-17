#!/usr/bin/env bash

koopa::indrops_i5_sample_index_counts() { # {{{1
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed 'awk' 'grep' 'gzip' 'head' 'sort' 'uniq'
    dir="${1:-.}"
    dir="$(koopa::strip_trailing_slash "$dir")"
    gzip -cd "${dir}/"*'_R3.fastq.gz' | \
        head -n -1000000 | \
        awk 'NR == 2 || NR % 4 == 2' | \
        grep -v N | \
        sort | \
        uniq -c | \
        sort -nr | \
        head -n 24 > \
        'sample-barcodes.log'
    return 0
}

