#!/usr/bin/env bash

# FIXME Rework and simplify this wrapper here.

koopa_sambamba_sort() {
    # """
    # Sort multiple BAM files in a directory.
    # @note Updated 2020-08-13.
    # """
    local bam_file bam_files dir
    koopa_assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa_assert_is_dir "$dir"
    dir="$(koopa_realpath "$dir")"
    # FIXME Rework using 'koopa_find'.
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.bam' \
            -not -iname '*.filtered.*' \
            -not -iname '*.sorted.*' \
            -print \
        | sort \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dir}'."
    fi
    koopa_alert "Sorting BAM files in '${dir}'."
    for bam_file in "${bam_files[@]}"
    do
        koopa_sambamba_sort_per_sample "$bam_file"
    done
    return 0
}
