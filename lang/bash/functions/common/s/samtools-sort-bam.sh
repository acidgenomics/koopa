#!/usr/bin/env bash

koopa_samtools_sort_bam() {
    # """
    # Sort a BAM file by genomic coordinates.
    # @note Updated 2023-10-23.
    #
    # Function is vectorized, supporting multiple BAM files.
    # Consider adding support for CRAM files in the future.
    #
    # @seealso
    # - samtools sort
    # - http://www.htslib.org/doc/samtools-sort.html
    # - Alternate approach with sambamba:
    #   https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    local -A app dict
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    dict['format']='bam'
    dict['threads']="$(koopa_cpu_count)"
    for file in "$@"
    do
        local -A dict2
        dict2['in_file']="$file"
        dict2['out_file']="${dict2['in_file']}.tmp"
        koopa_assert_is_matching_regex \
            --pattern="\.${dict['format']}\$" \
            --string="${dict2['in_file']}"
        koopa_alert "Sorting '${dict2['in_file']}'."
        "${app['samtools']}" sort \
            -@ "${dict['threads']}" \
            -O "${dict['format']}" \
            -o "${dict2['out_file']}" \
            "${dict2['in_file']}"
        koopa_assert_is_file "${dict2['out_file']}"
        koopa_rm "${dict2['in_file']}"
        koopa_mv "${dict2['out_file']}" "${dict2['in_file']}"
    done
    return 0
}
