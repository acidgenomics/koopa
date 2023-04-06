#!/usr/bin/env bash

koopa_debian_apt_space_used_by_no_deps() {
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local str
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt']="$(koopa_debian_locate_apt)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sudo']}" "${app['apt']}" show "$@" 2>/dev/null \
            | koopa_grep --pattern='Size' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
