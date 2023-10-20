#!/usr/bin/env bash

# FIXME Switch to a dict approach here.
# FIXME Rework our location of conda environment tool here instead.
# FIXME Also add bam sorting and indexing wrappers.
# FIXME Add minimap2 index function.
# FIXME Add minimap2 align function.

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
    local -A app
    local bam_bn input_sam output_bam sam_bn threads
    koopa_assert_has_args "$#"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app['samtools']}"
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
    if [[ -f "$output_bam" ]]
    then
        koopa_alert_note "Skipping '${bam_bn}'."
        return 0
    fi
    sam_bn="$(koopa_basename "$input_sam")"
    bam_bn="$(koopa_basename "$output_bam")"
    koopa_alert "Converting '${sam_bn}' to '${bam_bn}'."
    koopa_assert_is_file "$input_sam"
    threads="$(koopa_cpu_count)"
    "${app['samtools']}" view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}
