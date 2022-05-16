#!/usr/bin/env bash

koopa_update_koopa() { # {{{3
    # """
    # Update koopa installation.
    # @note Updated 2022-04-26.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_koopa_prefix)"
    )
    if ! koopa_is_git_repo_top_level "${dict[prefix]}"
    then
        koopa_alert_note "Pinned release detected at '${dict[prefix]}'."
        return 1
    fi
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_git_pull "${dict[prefix]}"
    # NOTE Add a step to recache Bash function library here.
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}
