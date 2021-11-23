#!/usr/bin/env bash

# FIXME Do we need a separate updater for dotfiles private?
# FIXME Harden this by using our desired version of Bash, to run the script.
# FIXME Need to wrap this.
# FIXME May need to ensure that permissions are correct here.
koopa:::update_dotfiles() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2021-11-18.
    # """
    local app repo repos script
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    if [[ "$#" -eq 0 ]]
    then
        repos=(
            "$(koopa::dotfiles_prefix)"
            "$(koopa::dotfiles_private_prefix)"
        )
    else
        repos=("$@")
    fi
    # FIXME Need to rework subshell approach here...
    for repo in "${repos[@]}"
    do
        [[ -d "$repo" ]] || continue
        (
            koopa::alert_update_start "$repo"
            koopa::cd "$repo"
            script="${repo}/update"
            if [[ -x "$script" ]]
            then
                "${app[bash]}" "$script"
            else
                # FIXME Can pass directory path in directly.
                koopa::git_reset
                # FIXME Can pass directory path in directly.
                koopa::git_pull
            fi
            script="${repo}/install"
            if [[ -x "$script" ]]
            then
                "${app[bash]}" "$script"
            fi
            koopa::alert_update_success "$repo"
        )
    done
    return 0
}
