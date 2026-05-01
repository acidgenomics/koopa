#!/usr/bin/env bash

_koopa_fastq_number_of_reads() {
    # """
    # Return the number of reads per FASTQ file.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_fastq_number_of_reads 'sample_R1.fastq.gz'
    # # 27584960
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local num
        # shellcheck disable=SC2016
        num="$( \
            "${app['wc']}" -l \
                <(_koopa_decompress --stdout "$file") \
            | "${app['awk']}" '{print $1/4}' \
        )"
        [[ -n "$num" ]] || return 1
        _koopa_print "$num"
    done
    return 0
}
