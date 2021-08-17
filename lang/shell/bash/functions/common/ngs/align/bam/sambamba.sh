#!/usr/bin/env bash

# FIXME Rework these functions in R.

koopa::sambamba_filter() { # {{{1
    # """
    # Perform filtering on a BAM file with sambamba.
    # @note Updated 2020-08-13.
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
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'sambamba'
    while (("$#"))
    do
        case "$1" in
            --filter=*)
                filter="${1#*=}"
                shift 1
                ;;
            --input-bam=*)
                input_bam="${1#*=}"
                shift 1
                ;;
            --output-bam=*)
                output_bam="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'filter' 'input_bam' 'output_bam'
    koopa::assert_are_not_identical "$input_bam" "$output_bam"
    input_bam_bn="$(basename "$input_bam")"
    output_bam_bn="$(basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        koopa::alert_note "Skipping '${output_bam_bn}'."
        return 0
    fi
    koopa::h2 "Filtering '${input_bam_bn}' to '${output_bam_bn}'."
    koopa::assert_is_file "$input_bam"
    koopa::dl 'Filter' "$filter"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
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

koopa::sambamba_filter_duplicates() { # {{{1
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       bam/__init__.py
    # """
    koopa::assert_has_args "$#"
    koopa::sambamba_filter --filter='not duplicate' "$@"
    return 0
}

koopa::sambamba_filter_multimappers() { # {{{1
    # """
    # Filter multi-mapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       chipseq/__init__.py
    # """
    koopa::assert_has_args "$#"
    koopa::sambamba_filter --filter='[XS] == null' "$@"
    return 0
}

koopa::sambamba_filter_unmapped() { # {{{1
    # """
    # Filter unmapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # """
    koopa::assert_has_args "$#"
    koopa::sambamba_filter --filter='not unmapped' "$@"
    return 0
}

koopa::sambamba_index() { # {{{1
    # """
    # Index BAM file with sambamba.
    # @note Updated 2020-08-12.
    # """
    local bam_file threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'samtools'
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    for bam_file in "$@"
    do
        koopa::alert "Indexing '${bam_file}'."
        koopa::assert_is_file "$bam_file"
        sambamba index \
            --nthreads="$threads" \
            --show-progress \
            "$bam_file"
    done
    return 0
}

koopa::sambamba_sort() { # {{{1
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
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'sambamba'
    unsorted_bam="${1:?}"
    sorted_bam="${unsorted_bam%.bam}.sorted.bam"
    unsorted_bam_bn="$(basename "$unsorted_bam")"
    sorted_bam_bn="$(basename "$sorted_bam")"
    if [[ -f "$sorted_bam" ]]
    then
        koopa::alert_note "Skipping '${sorted_bam_bn}'."
        return 0
    fi
    koopa::h2 "Sorting '${unsorted_bam_bn}' to '${sorted_bam_bn}'."
    koopa::assert_is_file "$unsorted_bam"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "${threads}"
    sambamba sort \
        --memory-limit='2GB' \
        --nthreads="$threads" \
        --out="$sorted_bam" \
        --show-progress \
        "$unsorted_bam"
    return 0
}
