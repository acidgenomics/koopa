#!/usr/bin/env bash

koopa_sambamba_index() {
    # """
    # Index BAM file with sambamba.
    # @note Updated 2022-10-11.
    # """
    local app bam_file dict
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    declare -A app
    app['sambamba']="$(koopa_locate_sambamba)"
    [[ -x "${app['sambamba']}" ]] || return 1
    declare -A dict
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
