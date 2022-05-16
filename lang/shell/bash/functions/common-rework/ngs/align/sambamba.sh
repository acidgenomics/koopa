#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

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

koopa_sambamba_filter_duplicates() {
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       bam/__init__.py
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not duplicate' "$@"
    return 0
}

koopa_sambamba_filter_multimappers() {
    # """
    # Filter multi-mapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       chipseq/__init__.py
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='[XS] == null' "$@"
    return 0
}

koopa_sambamba_filter_unmapped() {
    # """
    # Filter unmapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not unmapped' "$@"
    return 0
}

koopa_sambamba_index() {
    # """
    # Index BAM file with sambamba.
    # @note Updated 2020-08-12.
    # """
    local bam_file threads
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'samtools'
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "$threads"
    for bam_file in "$@"
    do
        koopa_alert "Indexing '${bam_file}'."
        koopa_assert_is_file "$bam_file"
        sambamba index \
            --nthreads="$threads" \
            --show-progress \
            "$bam_file"
    done
    return 0
}

koopa_sambamba_sort() {
    # """
    # Sort a BAM file by genomic coordinates.
    # @note Updated 2020-08-12.
    #
    # Sorts by genomic coordinates by default.
    # Use '-n' flag to sort by read name instead.
    #
    # @seealso
    # - https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    local sorted_bam sorted_bam_bn threads unsorted_bam unsorted_bam_bn
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'sambamba'
    unsorted_bam="${1:?}"
    sorted_bam="${unsorted_bam%.bam}.sorted.bam"
    unsorted_bam_bn="$(koopa_basename "$unsorted_bam")"
    sorted_bam_bn="$(koopa_basename "$sorted_bam")"
    if [[ -f "$sorted_bam" ]]
    then
        koopa_alert_note "Skipping '${sorted_bam_bn}'."
        return 0
    fi
    koopa_h2 "Sorting '${unsorted_bam_bn}' to '${sorted_bam_bn}'."
    koopa_assert_is_file "$unsorted_bam"
    threads="$(koopa_cpu_count)"
    koopa_dl 'Threads' "${threads}"
    sambamba sort \
        --memory-limit='2GB' \
        --nthreads="$threads" \
        --out="$sorted_bam" \
        --show-progress \
        "$unsorted_bam"
    return 0
}
