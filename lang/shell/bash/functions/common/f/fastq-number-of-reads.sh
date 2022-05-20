#!/usr/bin/env bash

koopa_fastq_number_of_reads() {
    # """
    # Return the number of reads per FASTQ file.
    # @note Updated 2022-05-18.
    #
    # @examples
    # > koopa_fastq_number_of_reads 'sample_R1.fastq.gz'
    # # 27584960
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [wc]="$(koopa_locate_wc)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[wc]}" ]] || return 1
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local num
        # shellcheck disable=SC2016
        num="$( \
            "${app[wc]}" -l \
                <(koopa_decompress --stdout "$file") \
            | "${app[awk]}" '{print $1/4}' \
        )"
        [[ -n "$num" ]] || return 1
        koopa_print "$num"
    done
    return 0
}
