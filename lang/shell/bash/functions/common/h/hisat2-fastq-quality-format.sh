#!/usr/bin/env bash

koopa_hisat2_fastq_quality_format() {
    # """
    # Determine whether we should set FASTQ quality score (Phred) flag.
    # @note Updated 2022-03-25.
    #
    # Consider adding support for Solexa sequencing here.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [fastq_file]="${1:?}"
    )
    koopa_assert_is_file "${dict[fastq_file]}"
    dict[format]="$(koopa_fastq_detect_quality_format "${dict[fastq_file]}")"
    case "${dict[format]}" in
        'Phread+33')
            dict[flag]='--phred33'
            ;;
        'Phread+64')
            dict[flag]='--phred64'
            ;;
        *)
            return 0
            ;;
    esac
    koopa_print "${dict[flag]}"
    return 0
}
