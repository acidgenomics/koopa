#!/usr/bin/env bash

koopa:::update_koopa() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2021-11-22.
    #
    # Update of pinned stable releases is intentionally not supported.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [dotfiles_prefix]="$(koopa::dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa::dotfiles_private_prefix)"
        [koopa_prefix]="${UPDATE_PREFIX:?}"
    )
    if ! koopa::is_git_repo_top_level "${dict[koopa_prefix]}"
    then
        koopa::alert_note "Pinned release detected at '${dict[koopa_prefix]}'."
        return 1
    fi
    koopa::sys_set_permissions --recursive "${dict[koopa_prefix]}"
    koopa::sys_git_pull
    koopa::update_dotfiles \
        "${dict[dotfiles_prefix]}" \
        "${dict[dotfiles_private_prefix]}"
    koopa::sys_set_permissions --recursive "${dict[koopa_prefix]}"
    koopa::fix_zsh_permissions
    return 0
}
