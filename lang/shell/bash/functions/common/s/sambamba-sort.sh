#!/usr/bin/env bash

koopa_sambamba_sort() {
    # """
    # Sort multiple BAM files in a directory.
    # @note Updated 2022-10-11.
    # """
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --exclude='*.filtered.*' \
            --exclude='*.sorted.*' \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.bam' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['prefix']}'."
    fi
    koopa_alert "Sorting BAM files in '${dict['prefix']}'."
    for bam_file in "${bam_files[@]}"
    do
        koopa_sambamba_sort_per_sample "$bam_file"
    done
    return 0
}
