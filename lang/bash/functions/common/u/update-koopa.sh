#!/usr/bin/env bash

koopa_update_koopa() {
    # """
    # Update koopa installation.
    # @note Updated 2024-07-05.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local -A dict
    local -a chown prefixes
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['group_id']="$(koopa_group_id)"
    dict['group_name']="$(koopa_group_name)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['user_id']="$(koopa_user_id)"
    dict['user_name']="$(koopa_user_name)"
    if ! koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['koopa_prefix']}'."
        return 1
    fi
    chown=('koopa_chown')
    koopa_is_shared_install && chown+=('--sudo')
    prefixes=(
        "${dict['koopa_prefix']}"
        "${dict['koopa_prefix']}/lang/zsh"
    )
    for prefix in "${prefixes[@]}"
    do
        if [[ "$(koopa_stat_user_id "$prefix")" == "${dict['user_id']}" ]] && \
            [[ "$(koopa_stat_group_id "$prefix")" == "${dict['group_id']}" ]]
        then
            continue
        fi
        koopa_alert "Resetting ownership of '${prefix}' to \
'${dict['user_name']}:${dict['group_name']}' \
(${dict['user_id']}:${dict['group_id']})."
        "${chown[@]}" --recursive \
            "${dict['user_id']}:${dict['group_id']}" \
            "$prefix"
    done
    koopa_git_pull "${dict['koopa_prefix']}"
    koopa_zsh_compaudit_set_permissions
    return 0
}
