#!/usr/bin/env bash

koopa_switch_to_develop() {
    # """
    # Switch koopa install to development version.
    # @note Updated 2022-02-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    declare -A dict=(
        [branch]='develop'
        [origin]='origin'
        [prefix]="$(koopa_koopa_prefix)"
    )
    koopa_alert "Switching koopa at '${dict[prefix]}' to '${dict[branch]}'."
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    (
        koopa_cd "${dict[prefix]}"
        "${app[git]}" checkout \
            -B "${dict[branch]}" \
            "${dict[origin]}/${dict[branch]}"
    )
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}
