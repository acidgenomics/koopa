#!/usr/bin/env bash

koopa_current_python_version() {
    # """
    # Get current Python version.
    # @note Updated 2026-01-02.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['curl']="$(koopa_locate_curl)"
    app['cut']="$(koopa_locate_cut)"
    app['grep']="$(koopa_locate_grep)"
    app['head']="$(koopa_locate_head)"
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['url']='https://www.python.org/ftp/python/'
    dict['grep_string']='3\.[0-9]+\.[0-9]+/'
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['cut']}" -d '/' -f 1 \
            | "${app['sort']}" -Vu \
            | "${app['tail']}" -n 2 \
            | "${app['head']}" -n 1 \
    )"
    koopa_print "${dict['version']}"
    return 0
}
