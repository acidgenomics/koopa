#!/usr/bin/env bash

# FIXME Need to rethink and rework this approach with 'koopa::git_pull':
# → Resetting repo at '/opt/koopa/app/dotfiles/rolling'.
# → Initializing submodules in '/opt/koopa/app/dotfiles/rolling'.
# shell/zsh/plugins/zsh-autosuggestions: https://github.com/zsh-users/zsh-autosuggestions.git
# shell/zsh/plugins/zsh-syntax-highlighting: https://github.com/zsh-users/zsh-syntax-highlighting.git
# → Pulling repo at '/opt/koopa/app/dotfiles/rolling'.
# Fetching origin
# hint: Pulling without specifying how to reconcile divergent branches is
# hint: discouraged. You can squelch this message by running one of the following
# hint: commands sometime before your next pull:
# hint:
# hint:   git config pull.rebase false  # merge (the default strategy)
# hint:   git config pull.rebase true   # rebase
# hint:   git config pull.ff only       # fast-forward only
# hint:
# hint: You can replace "git config" with "git config --global" to set a default
# hint: preference for all repositories. You can also pass --rebase, --no-rebase,
# hint: or --ff-only on the command line to override the configured default per
# hint: invocation.
# From https://github.com/acidgenomics/dotfiles
#  * branch            main       -> FETCH_HEAD
# Already up to date.
# → Initializing submodules in '/opt/koopa/app/dotfiles/rolling'.
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
