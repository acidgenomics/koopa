#!/usr/bin/env bash

koopa::configure_go() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        --which-app="$(koopa::locate_go)" \
        "$@"
}

koopa::configure_julia() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        --which-app="$(koopa::locate_julia)" \
        "$@"
}

koopa::configure_nim() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        --which-app="$(koopa::locate_nim)"
    return 0
}

koopa::configure_node() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        --which-app="$(koopa::locate_node)" \
        "$@"
}

# The 'koopa::git_pull' call here currently errors for repos in a detached
# HEAD state. Rework this.
koopa::configure_user() { # {{{1
    # """
    # Update koopa user configuration.
    # @note Updated 2021-11-18.
    # """
    local dict repo repos
    declare -A dict=(
        [config_prefix]="$(koopa::config_prefix)"
        [dotfiles_prefix]="$(koopa::dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa::dotfiles_private_prefix)"
        [local_data_prefix]="$(koopa::local_data_prefix)"
    )
    koopa::h1 'Updating user configuration.'
    # Remove legacy directories from user config, if necessary.
    koopa::rm \
        "${dict[config_prefix]}/Rcheck" \
        "${dict[config_prefix]}/home" \
        "${dict[config_prefix]}/oh-my-zsh" \
        "${dict[config_prefix]}/pyenv" \
        "${dict[config_prefix]}/rbenv" \
        "${dict[config_prefix]}/spacemacs"
    # Update git repos.
    repos=(
        "${dict[config_prefix]}/docker"
        "${dict[config_prefix]}/docker-private"
        "${dict[config_prefix]}/dotfiles-private"
        "${dict[config_prefix]}/scripts-private"
        "${dict[local_data_prefix]}/Rcheck"
    )
    for repo in "${repos[@]}"
    do
        [[ -d "$repo" ]] || continue
        (
            koopa::cd "$repo"
            # FIXME This currently errors when on HEAD (e.g. monorepo).
            koopa::git_pull
        )
    done
    if ! koopa::is_shared_install
    then
        koopa::update_dotfiles "${dict[dotfiles_prefix]}"
    fi
    koopa::update_dotfiles "${dict[dotfiles_private_prefix]}"
    koopa::alert_success 'User configuration update was successful.'
    return 0
}
