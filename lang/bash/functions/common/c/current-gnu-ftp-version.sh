#!/usr/bin/env bash

koopa_current_gnu_ftp_version() {
    # """
    # Get current version from GNU FTP server.
    # @note Updated 2025-12-30.
    #
    # @examples
    # $ koopa_current_gnu_ftp_version 'coreutils'
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['curl']="$(koopa_locate_curl)"
    app['cut']="$(koopa_locate_cut)"
    app['grep']="$(koopa_locate_grep)"
    app['head']="$(koopa_locate_head)"
    app['rev']="$(koopa_locate_rev)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['url']="https://ftp.gnu.org/gnu/${dict['name']}/?C=M;O=D"
    dict['grep_string']="${dict['name']}-[.0-9a-z]+.tar"
    dict['version']="$( \
        "${app['curl']}" --silent "${dict['url']}" \
            | "${app['grep']}" -Eo "${dict['grep_string']}" \
            | "${app['head']}" -n 1 \
            | "${app['cut']}" -d '-' -f '2' \
            | "${app['rev']}" \
            | "${app['cut']}" -d '.' -f '2-' \
            | "${app['rev']}" \
    )"
    koopa_print "${dict['version']}"
    return 0
}
