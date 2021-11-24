#!/usr/bin/env bash

# FIXME The 'git_pull' approach currently has submodule issue with 'main'
# branch.

# FIXME Need to rethink and rework this:
# shell/zsh/plugins/zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions.git
# shell/zsh/plugins/zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting.git
# error: pathspec 'main' did not match any file(s) known to git
# fatal: run_command returned non-zero status for shell/zsh/plugins/zsh-autosuggestions

koopa:::update_dotfiles() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2021-11-24.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    koopa::git_reset "${dict[prefix]}"
    koopa::git_pull "${dict[prefix]}"
    "${app[bash]}" "${dict[script]}"
    return 0
}
