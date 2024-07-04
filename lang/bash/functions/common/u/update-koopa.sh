#!/usr/bin/env bash

# FIXME Check if we need to update ownership after change in 2024-06.

koopa_update_koopa() {
    # """
    # Update koopa installation.
    # @note Updated 2023-05-18.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local -A dict
    local -a prefixes
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['user_id']="$(koopa_user_id)"
    if ! koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['koopa_prefix']}'."
        return 1
    fi
    prefixes=("${dict['koopa_prefix']}/lang/zsh")
    for prefix in "${prefixes[@]}"
    do
        if [[ "$(koopa_stat_user_id "$prefix")" == "${dict['user_id']}" ]]
        then
            continue
        fi
        koopa_alert "Fixing ownership of '${prefix}'."
        koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
    done
    koopa_git_pull "${dict['koopa_prefix']}"
    koopa_zsh_compaudit_set_permissions
    return 0
}
