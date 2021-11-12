#!/usr/bin/env bash

# FIXME Need to wrap this.
koopa::install_dotfiles_private() { # {{{1
    # """
    # Install private dotfiles.
    # @note Updated 2021-06-14.
    # """
    local name_fancy prefix script
    name='dotfiles-private'
    name_fancy='private dotfiles'
    prefix="$(koopa::dotfiles_private_prefix)"
    koopa::install_start "$name_fancy" "$prefix"
    koopa::add_monorepo_config_link "$name"
    koopa::assert_is_dir "$prefix"
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

# FIXME Need to wrap this.
koopa::uninstall_dotfiles_private() { # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2021-06-14.
    # """
    local name_fancy prefix script
    koopa::assert_has_no_args "$#"
    name_fancy='private dotfiles'
    prefix="$(koopa::dotfiles_private_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::alert_is_not_installed "$name_fancy" "$prefix"
        return 0
    fi
    script="${prefix}/uninstall"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}
