#!/usr/bin/env bash

# FIXME Need to parameterize this, supporting multiple SAMs.

koopa_samtools_convert_sam_to_bam() {
    # """
    # Convert a SAM file to BAM format.
    # @note Updated 2023-10-20.
    #
    # samtools view --help
    # Useful flags:
    # -1                    use fast BAM compression (implies -b)
    # -@, --threads         number of threads
    # -C                    output CRAM (requires -T)
    # -O, --output-fmt      specify output format (SAM, BAM, CRAM)
    # -T, --reference       reference sequence FASTA file
    # -b                    output BAM
    # -o FILE               output file name [stdout]
    # -u                    uncompressed BAM output (implies -b)
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app['samtools']}"
    dict['input_sam']=''
    dict['output_bam']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--input-sam='*)
                dict['input_sam']="${1#*=}"
                shift 1
                ;;
            '--input-sam')
                dict['input_sam']="${2:?}"
                shift 2
                ;;
            '--output-bam='*)
                dict['output_bam']="${1#*=}"
                shift 1
                ;;
            '--output-bam')
                dict['output_bam']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--input-sam' "${dict['input_sam']}" \
        '--output-bam' "${dict['output_bam']}"
    koopa_assert_is_file "${dict['input_sam']}"
    dict['input_sam']="$(koopa_realpath "${dict['input_sam']}")"
    if [[ -f "${dict['output_bam']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_bam']}'."
        return 0
    fi
    koopa_alert "Converting '${dict['input_sam']}' to '${dict['output_bam']}'."
    "${app['samtools']}" view \
        -@ "${dict['threads']}" \
        -b \
        -h \
        -o "${dict['output_bam']}" \
        "${dict['input_sam']}"
    koopa_assert_is_file "${dict['output_bam']}"
    return 0
}
