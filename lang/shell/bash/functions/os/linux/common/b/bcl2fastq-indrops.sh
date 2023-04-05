#!/usr/bin/env bash

koopa_linux_bcl2fastq_indrops() {
    # """
    # Run bcl2fastq on inDrops sequencing run.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app=(
        ['bcl2fastq']="$(koopa_linux_locate_bcl2fastq)"
        ['tee']="$(koopa_locate_tee)"
    )
    [[ -x "${app['bcl2fastq']}" ]] || exit 1
    [[ -x "${app['tee']}" ]] || exit 1
    local -A dict=(
        ['log_file']='bcl2fastq-indrops.log'
    )
    "${app['bcl2fastq']}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}
