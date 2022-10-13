#!/usr/bin/env bash

main() {
    # """
    # Update TeX packages.
    # @note Updated 2022-04-26.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
    declare -A app=(
        ['sudo']="$(koopa_locate_sudo)"
        ['tlmgr']="$(koopa_locate_tlmgr)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tlmgr']}" ]] || return 1
    "${app['sudo']}" "${app['tlmgr']}" update --self
    "${app['sudo']}" "${app['tlmgr']}" update --list
    "${app['sudo']}" "${app['tlmgr']}" update --all
    return 0
}
