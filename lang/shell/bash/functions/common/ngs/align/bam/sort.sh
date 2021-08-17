#!/usr/bin/env bash

# FIXME Rework these functions in R.

koopa::bam_sort() { # {{{1
    # """
    # Sort multiple BAM files in a directory.
    # @note Updated 2020-08-13.
    # """
    local bam_file bam_files dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
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
    if ! koopa::is_array_non_empty "${bam_files[@]:-}"
    then
        koopa::stop "No BAM files detected in '${dir}'."
    fi
    koopa::h1 "Sorting BAM files in '${dir}'."
    koopa::activate_conda_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        koopa::sambamba_sort "$bam_file"
    done
    return 0
}
