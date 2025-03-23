#!/usr/bin/env bash

# TODO This should automatically update all installed apps as well.
# TODO Consider adding adding automatic app pruning here too.

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
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    if ! koopa_is_git_repo_top_level "${dict['koopa_prefix']}"
    then
        koopa_alert_note "Pinned release detected at '${dict['koopa_prefix']}'."
        return 1
    fi
    koopa_git_pull "${dict['koopa_prefix']}"
    koopa_zsh_compaudit_set_permissions
    return 0
}
