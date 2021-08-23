#!/usr/bin/env bash

# FIXME Need to migrate these functions to r-koopa.
# FIXME Need to split this out per file
# FIXME What's up with the head call here?

koopa::indrops_i5_sample_index_counts() { # {{{1
    # """
    # Get the sample index counts from single-cell RNA-seq FASTQ files.
    # @note Updated 2021-08-23.
    # """
    local app dir file files log_file
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [find]="$(koopa::locate_find)"
        [grep]="$(koopa::locate_grep)"
        [gzip]="$(koopa::locate_gzip)"
        [head]="$(koopa::locate_head)"
        [sort]="$(koopa::locate_sort)"
        [uniq]="$(koopa::locate_uniq)"
    )
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    readarray -t files <<< "$( \
        "${app[find]}" "$dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -name "*_R3.fastq.gz" \
            -not -name '._*' \
            -print \
        | "${app[sort]}" \
    )"
    for file in "${files[@]}"
    do
        koopa::alert "Processing '${file}'."
        # FIXME Need to improve the log file name here.
        log_file="${file}-sample-barcodes.log"
        "${app[gzip]}" -cd "$file" | \
            "${app[head]}" --lines=-1000000 | \
            "${app[awk]}" 'NR == 2 || NR % 4 == 2' | \
            "${app[grep]}" --invert-match 'N' | \
            "${app[uniq]}" --count | \
            "${app[sort]}" --numeric-sort --reverse | \
            "${app[head]}" --lines=24 > \
            "$log_file"
    done
    return 0
}

