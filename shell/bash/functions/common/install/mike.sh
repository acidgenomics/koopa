#!/usr/bin/env bash

koopa::install_mike() { # {{{1
    # """
    # Install additional Mike-specific config files.
    # @note Updated 2020-07-07.
    #
    # Note that these repos require SSH key to be set on GitHub.
    # """
    koopa::assert_has_no_args "$#"
    koopa::install_dotfiles
    koopa::install_dotfiles_private
    koopa::add_monorepo_config_link \
        'docker' \
        'dotfiles-private' \
        'scripts-private'
    return 0
}
