#!/usr/bin/env bash

koopa_linux_bcl2fastq_indrops() {
    # """
    # Run bcl2fastq on inDrops sequencing run.
    # @note Updated 2023-05-23.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['bcl2fastq']="$(koopa_linux_locate_bcl2fastq)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['log_file']='bcl2fastq-indrops.log'
    # FIXME Rework the tee call here.
    "${app['bcl2fastq']}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}
