#!/usr/bin/env bash

koopa_samtools_index_bam() {
    # """
    # Index a BAM file with samtools.
    # @note Updated 2023-10-23.
    #
    # Function is vectorized, supporting multiple BAM files.
    # Consider adding support for CRAM files in the future.
    #
    # @seealso
    # - samtools index
    # - http://www.htslib.org/doc/samtools-index.html
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app['samtools']}"
    dict['threads']="$(koopa_cpu_count)"
    "${app['samtools']}" index \
        -@ "${dict['threads']}" \
        -M \
        -b \
        "$@"
    return 0
}
