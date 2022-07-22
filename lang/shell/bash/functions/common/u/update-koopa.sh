#!/usr/bin/env bash

koopa_update_koopa() {
    # """
    # Update koopa installation.
    # @note Updated 2022-07-22.
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
        [user]="$(koopa_user)"
    )
    if ! koopa_is_git_repo_top_level "${dict[prefix]}"
    then
        koopa_alert_note "Pinned release detected at '${dict[prefix]}'."
        return 1
    fi
    koopa_chown --recursive --sudo "${dict[user]}" "${dict[prefix]}"
    koopa_git_pull "${dict[prefix]}"
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}
