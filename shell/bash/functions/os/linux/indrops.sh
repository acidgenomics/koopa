#!/usr/bin/env bash

koopa::bcl2fastq_indrops() {
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed bcl2fastq
    bcl2fastq \
        --use-bases-mask y*,y*,y*,y* \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | tee "bcl2fastq-indrops.log"
    return 0
}

