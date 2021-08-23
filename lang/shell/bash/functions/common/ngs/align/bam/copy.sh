#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

koopa::copy_bam_files() { # {{{1
    # """
    # Copy BAM files.
    # @note Updated 2020-12-31.
    #
    # Intended primarily for use with bcbio-nextgen.
    # """
    local source_dir target_dir
    koopa::assert_has_args "$#"
    source_dir="$(koopa::realpath "${1:?}")"
    target_dir="$(koopa::realpath "${2:?}")"
    koopa::dl 'Source' "${source_dir}"
    koopa::dl 'Target' "${target_dir}"
    find -L "$source_dir" \
        -maxdepth 4 \
        -type f \
        \( -name '*.bam' -or -name '*.bam.bai' \) \
        ! -name '*-transcriptome.bam' \
        ! -path '*/work/*' \
        -print0 | xargs -0 -I {} \
            koopa::rsync --size-only {} "${target_dir}/"
    return 0
}
