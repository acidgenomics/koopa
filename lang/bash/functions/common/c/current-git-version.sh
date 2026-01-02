#!/usr/bin/env bash

koopa_current_git_version() {
    # """
    # Get current Git version.
    # @note Updated 2026-01-02.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['curl']="$(koopa_locate_curl)"
    app['cut']="$(koopa_locate_cut)"
    app['grep']="$(koopa_locate_grep)"
    app['rev']="$(koopa_locate_rev)"
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
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
    koopa_print "${dict['version']}"
    return 0
}
