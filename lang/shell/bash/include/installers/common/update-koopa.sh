#!/usr/bin/env bash

# FIXME This needs to check if top level is not set to current user, and
# adjust accordingly. Previously this was root for shared installs.

update_koopa() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2022-04-05.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    if ! koopa_is_git_repo_top_level "${dict[prefix]}"
    then
        koopa_alert_note "Pinned release detected at '${dict[prefix]}'."
        return 1
    fi
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_git_pull "${dict[prefix]}"
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_fix_zsh_permissions
    return 0
}
