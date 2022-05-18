#!/usr/bin/env bash

koopa_debian_apt_space_used_by_no_deps() {
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2021-11-02.
    # """
    local app x
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt]="$(koopa_debian_locate_apt)"
        [sudo]="$(koopa_locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt]}" show "$@" 2>/dev/null \
            | koopa_grep --pattern='Size' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
