#!/usr/bin/env bash

koopa_debian_apt_space_used_by_grep() {
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local app x
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [cut]="$(koopa_locate_cut)"
        [sudo]="$(koopa_locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt_get]}" \
            --assume-no \
            autoremove "$@" \
        | koopa_grep --pattern='freed' \
        | "${app[cut]}" -d ' ' -f '4-5' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
