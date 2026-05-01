#!/usr/bin/env bash

_koopa_current_git_version() {
    # """
    # Get current Git version.
    # @note Updated 2026-01-02.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['rev']="$(_koopa_locate_rev)"
    app['sort']="$(_koopa_locate_sort)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']='https://mirrors.edge.kernel.org/pub/software/scm/git/'
    dict['grep_string']='git-[.0-9]+\.tar\.xz'
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['sort']}" -u \
            | "${app['tail']}" -n 1 \
            | "${app['cut']}" -d '-' -f '2' \
            | "${app['rev']}" \
            | "${app['cut']}" -d '.' -f '3-' \
            | "${app['rev']}" \
    )"
    _koopa_print "${dict['version']}"
    return 0
}
