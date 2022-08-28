#!/usr/bin/env bash

koopa_md5sum_check_to_new_md5_file() {
    # """
    # Perform md5sum check on specified files to a new log file.
    # @note Updated 2021-11-04.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['md5sum']="$(koopa_locate_md5sum)"
        ['tee']="$(koopa_locate_tee)"
    )
    [[ -x "${app['md5sum']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        ['datetime']="$(koopa_datetime)"
    )
    dict['log_file']="md5sum-${dict['datetime']}.md5"
    koopa_assert_is_not_file "${dict['log_file']}"
    koopa_assert_is_file "$@"
    "${app['md5sum']}" "$@" 2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}
