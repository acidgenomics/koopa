#!/usr/bin/env bash

# FIXME Rework our location of conda environment tool here instead.
# FIXME Rework using a dl approach here.

koopa_samtools_convert_sam_to_bam() {
    # """
    # Convert a SAM file to BAM format.
    # @note Updated 2022-06-20.
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
    local bam_bn input_sam output_bam sam_bn threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'samtools'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--input-sam='*)
                input_sam="${1#*=}"
                shift 1
                ;;
            '--input-sam')
                input_sam="${2:?}"
                shift 2
                ;;
            '--output-bam='*)
                output_bam="${1#*=}"
                shift 1
                ;;
            '--output-bam')
                output_bam="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    # FIXME Rethink this approach, reworking using dict approach.
    koopa_assert_is_set \
        '--input-sam' "$input_sam" \
        '--output-bam' "$output_bam"
    sam_bn="$(koopa_basename "$input_sam")"
    bam_bn="$(koopa_basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa_alert_note "Skipping '${bam_bn}'."
        return 0
    fi
    koopa_h2 "Converting '${sam_bn}' to '${bam_bn}'."
    koopa_assert_is_file "$input_sam"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    "${app[samtools]}" view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}
