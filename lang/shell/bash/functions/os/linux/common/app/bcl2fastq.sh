#!/usr/bin/env bash

koopa::linux_bcl2fastq_indrops() { # {{{1
    # """
    # Run bcl2fastq on inDrops sequencing run.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bcl2fastq]="$(koopa::linux_locate_bcl2fastq)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [log_file]='bcl2fastq-indrops.log'
    )
    "${app[bcl2fastq]}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
