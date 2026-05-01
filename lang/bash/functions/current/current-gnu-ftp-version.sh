#!/usr/bin/env bash

_koopa_current_gnu_ftp_version() {
    # """
    # Get current version from GNU FTP server.
    # @note Updated 2025-12-30.
    #
    # @examples
    # $ _koopa_current_gnu_ftp_version 'coreutils'
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['curl']="$(_koopa_locate_curl)"
    app['cut']="$(_koopa_locate_cut)"
    app['grep']="$(_koopa_locate_grep)"
    app['head']="$(_koopa_locate_head)"
    app['rev']="$(_koopa_locate_rev)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['url']="https://ftp.gnu.org/gnu/${dict['name']}/?C=M;O=D"
    dict['grep_string']="${dict['name']}-[.0-9a-z]+.tar"
    dict['version']="$( \
        "${app['curl']}" -s "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '-' -f '2' \
            | "${app['rev']}" \
            | "${app['cut']}" -d '.' -f '2-' \
            | "${app['rev']}" \
    )"
    _koopa_print "${dict['version']}"
    return 0
}
