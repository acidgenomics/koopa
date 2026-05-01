#!/usr/bin/env bash

_koopa_debian_apt_space_used_by_grep() {
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2023-05-01.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local -A app
    local str
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['apt_get']="$(_koopa_debian_locate_apt_get)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        _koopa_sudo \
            "${app['apt_get']}" \
                --assume-no \
                autoremove "$@" \
        | _koopa_grep --pattern='freed' \
        | "${app['cut']}" -d ' ' -f '4-5' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
