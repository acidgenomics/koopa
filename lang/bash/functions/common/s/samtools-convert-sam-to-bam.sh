#!/usr/bin/env bash

koopa_samtools_convert_sam_to_bam() {
    # """
    # Convert a SAM file to BAM format.
    # @note Updated 2023-10-23.
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
    local file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(koopa_cpu_count)"
    for file in "$@"
    do
        local -A dict2
        dict2['sam_file']="$file"
        koopa_assert_is_matching_regex \
            --pattern='\.sam$' \
            --string="${dict2['sam_file']}"
        dict2['bam_file']="$( \
            koopa_sub \
                --pattern='\.sam$' \
                --regex \
                --replacement='.bam' \
                "${dict2['sam_file']}" \
        )"
        if [[ -f "${dict2['bam_file']}" ]]
        then
            koopa_alert_note "Skipping '${dict2['bam_file']}'."
            return 0
        fi
        koopa_alert "Converting '${dict2['sam_file']}' to \
'${dict2['bam_file']}'."
        "${app['samtools']}" view \
            -@ "${dict['threads']}" \
            -b \
            -h \
            -o "${dict2['bam_file']}" \
            "${dict2['sam_file']}"
        koopa_assert_is_file "${dict2['bam_file']}"
    done
    return 0
}
