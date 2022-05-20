#!/usr/bin/env bash

koopa_sambamba_filter() {
    # """
    # Perform filtering on a BAM file with sambamba.
    # @note Updated 2021-09-21.
    #
    # sambamba prints version information into stderr.
    #
    # @seealso
    # - https://lomereiter.github.io/sambamba/docs/sambamba-view.html
    # - https://github.com/lomereiter/sambamba/wiki/
    #       %5Bsambamba-view%5D-Filter-expression-syntax
    # - https://hbctraining.github.io/In-depth-NGS-Data-Analysis-Course/
    #       sessionV/lessons/03_align_and_filtering.html
    # """
    local filter input_bam input_bam_bn output_bam output_bam_bn threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'sambamba'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--filter='*)
                filter="${1#*=}"
                shift 1
                ;;
            '--filter')
                filter="${2:?}"
                shift 2
                ;;
            '--input-bam='*)
                input_bam="${1#*=}"
                shift 1
                ;;
            '--input-bam')
                input_bam="${2:?}"
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
    # FIXME Rework this.
    koopa_assert_is_set \
        '--filter' "$filter" \
        '--intput-bam' "$input_bam" \
        '--output-bam' "$output_bam"
    koopa_assert_are_not_identical "$input_bam" "$output_bam"
    input_bam_bn="$(koopa_basename "$input_bam")"
    output_bam_bn="$(koopa_basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa_alert_note "Skipping '${output_bam_bn}'."
        return 0
    fi
    koopa_h2 "Filtering '${input_bam_bn}' to '${output_bam_bn}'."
    koopa_assert_is_file "$input_bam"
    koopa_dl 'Filter' "$filter"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    sambamba view \
        --filter="$filter" \
        --format='bam' \
        --nthreads="$threads" \
        --output-filename="$output_bam" \
        --show-progress \
        --with-header \
        "$input_bam"
    return 0
}
