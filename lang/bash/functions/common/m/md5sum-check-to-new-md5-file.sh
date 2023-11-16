#!/usr/bin/env bash

koopa_md5sum_check_to_new_md5_file() {
    # """
    # Perform md5sum check on specified files to a new log file.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['md5sum']="$(koopa_locate_md5sum)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['datetime']="$(koopa_datetime)"
    dict['log_file']="md5sum-${dict['datetime']}.md5"
    koopa_assert_is_not_file "${dict['log_file']}"
    koopa_assert_is_file "$@"
    # FIXME May need to rework the tee call here.
    "${app['md5sum']}" "$@" 2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}
