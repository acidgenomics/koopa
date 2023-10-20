#!/usr/bin/env bash

# FIXME Ensure we handle strandedness automatically here.
# FIXME Consider adding 'koopa_rsem_fastq_library_type' function, similar to HISAT2
# for automatic strandedness handling.

koopa_rsem_align_paired_end_per_sample() {
    # """
    # Align paired-end samples with RSEM.
    # @note Updated 2023-10-20.
    #
    # Can use '--alignments' mode to quantify from BAM/CRAM/SAM.
    #
    # For Illumina TruSeq Stranded protocols, use '--strandedness reverse'.
    #
    # @seealso
    # - https://deweylab.github.io/RSEM/rsem-calculate-expression.html
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
    # """
    local -A app dict
    local -a align_args
    app['rsem_calculate_expression']="$(koopa_locate_rsem_calculate_expression)"
    koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(koopa_cpu_count)"
    align_args+=(
        '--paired-end'
        '--strandedness' 'none'
        '--num-threads' "${dict['threads']}"
        'CORE FLAG'
        'PAIRED FLAG'
        "FIXME INDEX DIR"
        "FIXME SAMPLE NAME"
    )
    return 0
}
