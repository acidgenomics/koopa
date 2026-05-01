#!/usr/bin/env bash

_koopa_debian_apt_space_used_by_no_deps() {
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt']="$(_koopa_debian_locate_apt)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_sudo \
            "${app['apt']}" show "$@" 2>/dev/null \
            | _koopa_grep --pattern='Size' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
