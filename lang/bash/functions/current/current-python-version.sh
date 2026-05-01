#!/usr/bin/env bash

_koopa_current_python_version() {
    # """
    # Get current Python version.
    # @note Updated 2026-01-02.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['head']="$(_koopa_locate_head)"
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
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
    _koopa_print "${dict['version']}"
    return 0
}
