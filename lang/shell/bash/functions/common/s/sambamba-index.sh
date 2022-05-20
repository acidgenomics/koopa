#!/usr/bin/env bash

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
