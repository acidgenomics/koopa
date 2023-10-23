#!/usr/bin/env bash

koopa_samtools_sort_bam() {
    # """
    # Sort a BAM file by genomic coordinates.
    # @note Updated 2023-10-22.
    #
    # Function is vectorized, supporting multiple BAM files.
    #
    # Can increase verbosity with:
    # --verbosity INT
    #     Set level of verbosity
    #
    # @seealso
    # - http://www.htslib.org/doc/samtools-sort.html
    # - Alternate approach with sambamba:
    #   https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    local -A app dict
    local file
    koopa_assert_has_args "$#"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    dict['format']='bam'
    dict['threads']="$(koopa_cpu_count)"
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict2
        dict2['in_file']="$file"
        dict2['out_file']="${dict2['infile']}.tmp"
        koopa_assert_is_matching_regex \
            --pattern="\.${dict['format']}\$" \
            --string="${dict['in_file']}"
        koopa_alert "Sorting '${dict['in_file']}'."
        "${app['samtools']}" sort \
            -@ "${dict['threads']}" \
            -O "${dict['format']}" \
            -o "${dict['out_file']}" \
            "${dict['in_file']}"
        koopa_assert_is_file "${dict2['out_file']}"
        koopa_rm "${dict2['in_file']}"
        koopa_mv "${dict2['out_file']}" "${dict2['in_file']}"
    done
    return 0
}
