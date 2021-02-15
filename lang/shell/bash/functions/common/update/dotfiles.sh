#!/usr/bin/env bash

koopa::update_dotfiles() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2021-01-19.
    # """
    local repo repos script
    koopa::assert_has_args "$#"
    repos=("$@")
    for repo in "${repos[@]}"
    do
        [[ -d "$repo" ]] || continue
        (
            koopa::update_start "$repo"
            koopa::cd "$repo"
            koopa::git_reset
            koopa::git_pull
            # Run the install script, if defined.
            script="${repo}/install"
            [[ -x "$script" ]] && "$script"
            koopa::update_success "$repo"
        )
    done
    return 0
}
