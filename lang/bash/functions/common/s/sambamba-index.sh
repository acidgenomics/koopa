#!/usr/bin/env bash

# FIXME Just do this with samtools...more common.

koopa_sambamba_index() {
    # """
    # Index BAM file with sambamba.
    # @note Updated 2022-10-11.
    # """
    local -A app dict
    local bam_file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['sambamba']="$(koopa_locate_sambamba)"
    koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(koopa_cpu_count)"
    for bam_file in "$@"
    do
        koopa_assert_is_matching_regex \
            --pattern='\.bam$' \
            --string="$bam_file"
        koopa_alert "Indexing '${bam_file}'."
        "${app['sambamba']}" index \
            --nthreads="${dict['threads']}" \
            --show-progress \
            "$bam_file"
    done
    return 0
}