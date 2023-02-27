#!/usr/bin/env bash

koopa_update_koopa() {
    # """
    # Update koopa installation.
    # @note Updated 2023-02-27.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    declare -A dict=(
        ['prefix']="$(koopa_koopa_prefix)"
        ['user']="$(koopa_user)"
    )
    if ! koopa_is_git_repo_top_level "${dict['prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['prefix']}'."
        return 1
    fi
    koopa_git_pull "${dict['prefix']}"
    koopa_zsh_compaudit_set_permissions
    return 0
}
