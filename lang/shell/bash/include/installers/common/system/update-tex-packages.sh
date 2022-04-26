#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update TeX packages.
    # @note Updated 2021-11-13.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tlmgr]="$(koopa_locate_tlmgr)"
    )
    "${app[sudo]}" "${app[tlmgr]}" update --self
    "${app[sudo]}" "${app[tlmgr]}" update --list
    "${app[sudo]}" "${app[tlmgr]}" update --all
    return 0
}
