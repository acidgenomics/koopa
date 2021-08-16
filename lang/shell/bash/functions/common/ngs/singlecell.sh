#!/usr/bin/env bash

# NOTE Consider rewriting this in Python or R.

koopa::indrops_i5_sample_index_counts() { # {{{1
    # """
    # Get the sample index counts from single-cell RNA-seq FASTQ files.
    # @note Updated 2021-08-16.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::strip_trailing_slash "$dir")"
    # Ensure coreutils are hardened.
    awk="$(koopa::locate_awk)"
    grep="$(koopa::locate_grep)"
    gzip="$(koopa::locate_gzip)"
    head="$(koopa::locate_head)"
    sort="$(koopa::locate_sort)"
    uniq="$(koopa::locate_uniq)"
    # Now we're ready to chain the commands that evaluate our R3 FASTQ files.
    "$gzip" -cd "${dir}/"*'_R3.fastq.gz' | \
        "$head" -n -1000000 | \
        "$awk" 'NR == 2 || NR % 4 == 2' | \
        "$grep" -v N | \
        "$sort" | \
        "$uniq" -c | \
        "$sort" -nr | \
        "$head" -n 24 > \
        'sample-barcodes.log'
    return 0
}

