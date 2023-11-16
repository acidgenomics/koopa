#!/usr/bin/env bash

koopa_bam_read_type() {
    # """
    # Does the input BAM file contain paired-end or single-end reads?
    # @note Updated 2023-11-13.
    #
    # @seealso
    # - https://www.biostars.org/p/178730/
    #
    # @examples
    # koopa_bam_read_type 'sample1.bam'
    # # paired
    # """
    local -A app dict
    local bam_file
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    dict['threads']="$(koopa_cpu_count)"
    for bam_file in "$@"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['num']="$( \
            "${app['samtools']}" view \
                -@ "${dict['threads']}" \
                -c \
                -f 1 \
                "${dict2['bam_file']}" \
        )"
        if [[ "${dict2['num']}" -gt 0 ]]
        then
            dict2['type']='paired'
        else
            dict2['type']='single'
        fi
        koopa_print "${dict2['type']}"
    done
    return 0
}
