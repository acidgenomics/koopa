#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update TeX packages.
    # @note Updated 2022-04-26.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'curl' 'gnupg' 'wget'
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tlmgr]="$(koopa_locate_tlmgr)"
    )
    "${app[sudo]}" "${app[tlmgr]}" update --self
    "${app[sudo]}" "${app[tlmgr]}" update --list
    "${app[sudo]}" "${app[tlmgr]}" update --all
    return 0
}
