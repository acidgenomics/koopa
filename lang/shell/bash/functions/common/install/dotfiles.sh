#!/usr/bin/env bash

koopa::install_dotfiles() { # {{{1
    # """
    # Install dot files.
    # @note Updated 2020-07-07.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_prefix)"
    [[ ! -d "$prefix" ]] && koopa::git_clone_dotfiles
    koopa::add_config_link "$prefix"
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::install_dotfiles_private() { # {{{1
    # """
    # Install private dot files.
    # @note Updated 2020-07-07.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_private_prefix)"
    koopa::add_monorepo_config_link 'dotfiles-private'
    [[ ! -d "$prefix" ]] && koopa::git_clone_dotfiles_private
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}
