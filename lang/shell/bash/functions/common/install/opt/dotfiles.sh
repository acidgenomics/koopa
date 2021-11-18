#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Need to run uninstall script with specific Bash.
koopa::uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dot files.
    # @note Updated 2021-06-14.
    # """
    local name name_fancy prefix script
    koopa::assert_has_no_args "$#"
    name='dotfiles'
    name_fancy='dotfiles'
    prefix="$(koopa::dotfiles_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::alert_is_not_installed "$name_fancy" "$prefix"
        return 0
    fi
    script="${prefix}/uninstall"
    koopa::assert_is_file "$script"
    "$script"
    koopa::uninstall_app \
        --name-fancy="$name_fancy" \
        --name="$name" \
        "$@"
    return 0
}

# FIXME Harden this by using our desired version of Bash, to run the script.
# FIXME Need to wrap this.
# FIXME May need to ensure that permissions are correct here.
koopa::update_dotfiles() { # {{{1
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
                koopa::git_reset
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
