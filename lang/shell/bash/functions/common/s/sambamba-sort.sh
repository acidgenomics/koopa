#!/usr/bin/env bash

# FIXME Need to locate sambamba here.

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
