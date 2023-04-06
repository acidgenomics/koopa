#!/usr/bin/env bash

koopa_is_file_system_case_sensitive() {
    # """
    # Is the file system case sensitive?
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['find']="$(koopa_locate_find)"
    app['wc']="$(koopa_locate_wc)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${PWD:?}"
    dict['tmp_stem']='.koopa.tmp.'
    dict['file1']="${dict['tmp_stem']}checkcase"
    dict['file2']="${dict['tmp_stem']}checkCase"
    koopa_touch "${dict['file1']}" "${dict['file2']}"
    dict['count']="$( \
        "${app['find']}" \
            "${dict['prefix']}" \
            -maxdepth 1 \
            -mindepth 1 \
            -name "${dict['file1']}" \
        | "${app['wc']}" -l \
    )"
    koopa_rm "${dict['tmp_stem']}"*
    [[ "${dict['count']}" -eq 2 ]]
}
