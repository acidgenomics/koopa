#!/usr/bin/env bash

# FIXME Move this back to POSIX library.

koopa_is_os_like() {
    # """
    # Does the current operating system match an expected distribution?
    # @note Updated 2023-01-10.
    #
    # For example, this will match both Debian and Ubuntu when checking against
    # 'debian' value.
    # """
    local app dict
    declare -A app dict
    dict['id']="${1:?}"
    koopa_is_os "${dict['id']}" && return 0
    dict['file']='/etc/os-release'
    [[ -r "${dict['file']}" ]] || return 1
    app['grep']="$(koopa_locate_grep --allow-system)"
    [[ -x "${app['grep']}" ]] || return 1
    "${app['grep']}" 'ID=' "${dict['file']}" \
        | "${app['grep']}" -q "${dict['id']}" \
        && return 0
    "${app['grep']}" 'ID_LIKE=' "${dict['file']}" \
        | "${app['grep']}" -q "${dict['id']}" \
        && return 0
    return 1
}
