#!/usr/bin/env bash

koopa_debian_apt_space_used_by_grep() {
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2023-04-05.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local -A app
    local str
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['sudo']="$(koopa_locate_sudo --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sudo']}" "${app['apt_get']}" \
            --assume-no \
            autoremove "$@" \
        | koopa_grep --pattern='freed' \
        | "${app['cut']}" -d ' ' -f '4-5' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
