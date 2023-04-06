#!/usr/bin/env bash

koopa_view_latest_tmp_log_file() {
    # """
    # View the latest temporary log file.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="${TMPDIR:-/tmp}"
    dict['user_id']="$(koopa_user_id)"
    dict['log_file']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="koopa-${dict['user_id']}-*" \
            --prefix="${dict['tmp_dir']}" \
            --sort \
            --type='f' \
        | "${app['tail']}" -n 1 \
    )"
    if [[ ! -f "${dict['log_file']}" ]]
    then
        koopa_stop "No koopa log file detected in '${dict['tmp_dir']}'."
    fi
    koopa_alert "Viewing '${dict['log_file']}'."
    # The use of '+G' flag here forces pager to return at end of line.
    koopa_pager +G "${dict['log_file']}"
    return 0
}
