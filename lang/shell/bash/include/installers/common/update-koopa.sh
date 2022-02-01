#!/usr/bin/env bash

# FIXME sys_set_permissions needs to ensure g+w recursively.
# FIXME This doesn't seem to be happening correctly at the moment.
# FIXME Need to ensure that installer also sets permissions correctly
# to 'root:sudo' with g+w for all files.

koopa:::update_koopa() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2022-02-02.
    #
    # Update of pinned stable releases is intentionally not supported.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    if ! koopa::is_git_repo_top_level "${dict[prefix]}"
    then
        koopa::alert_note "Pinned release detected at '${dict[prefix]}'."
        return 1
    fi
    echo 'FIXME AAA'
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::git_pull "${dict[prefix]}"
    echo 'FIXME BBB'
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::fix_zsh_permissions
    return 0
}
