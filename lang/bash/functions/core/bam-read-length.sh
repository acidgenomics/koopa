#!/usr/bin/env bash

_koopa_bam_read_length() {
    # """
    # Detect the length of mapped reads in a BAM file.
    # @note Updated 2023-11-13.
    #
    # @seealso
    # - https://www.biostars.org/p/65216/#65226
    #
    # @examples
    # > _koopa_bam_read_length 'sample1.bam'
    # # 150
    # """
    local -A app dict
    local bam_file
    _koopa_assert_has_args "$#"
    _koopa_assert_is_file "$@"
    app['awk']="$(_koopa_locate_awk)"
    app['head']="$(_koopa_locate_head)"
    app['samtools']="$(_koopa_locate_samtools)"
    app['sort']="$(_koopa_locate_sort)"
    _koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(_koopa_cpu_count)"
    for bam_file in "$@"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        # Using 'true' here to avoid 141 pipefail return error code.
        # shellcheck disable=SC2016
        dict2['num']="$( \
            "${app['samtools']}" view \
                -@ "${dict['threads']}" \
                "${dict2['bam_file']}" \
            | "${app['head']}" -n 1000000 \
            | "${app['awk']}" '{print length($10)}' \
            | "${app['sort']}" -nu \
            | "${app['head']}" -n 1 \
            || true \
        )"
        [[ -n "${dict2['num']}" ]] || return 1
        _koopa_print "${dict2['num']}"
    done
    return 0
}
