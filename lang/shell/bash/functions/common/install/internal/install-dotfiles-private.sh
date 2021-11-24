#!/usr/bin/env bash

koopa:::install_dotfiles_private() { # {{{1
    # """
    # Install private dotfiles.
    # @note Updated 2021-11-23.
    # """
    local app dict
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    koopa::assert_is_dir "${dict[prefix]}"

    # FIXME Split this out to separate configure function -------------
    koopa::add_monorepo_config_link 'dotfiles-private'
    dict[script]="${prefix}/install"
    koopa::assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    # FIXME Split this out to separate configure function -----------

    return 0
}
