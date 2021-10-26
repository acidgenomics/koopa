#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

koopa::samtools_convert_sam_to_bam() { # {{{1
    # """
    # Convert a SAM file to BAM format.
    # @note Updated 2021-09-21.
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
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'samtools'
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'input_sam' 'output_bam'
    sam_bn="$(koopa::basename "$input_sam")"
    bam_bn="$(koopa::basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa::alert_note "Skipping '${bam_bn}'."
        return 0
    fi
    koopa::h2 "Converting '${sam_bn}' to '${bam_bn}'."
    koopa::assert_is_file "$input_sam"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    samtools view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}
