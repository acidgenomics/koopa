#!/usr/bin/env bash

# FIXME Call Bash here instead of running script directly.
# FIXME Should I rework this monorepo approach here?
# FIXME Need to wrap this.
koopa:::install_dotfiles_private() { # {{{1
    # """
    # Install private dotfiles.
    # @note Updated 2021-11-18.
    # """
    local prefix script
    koopa::add_monorepo_config_link 'dotfiles-private'
    # FIXME INSTALL_PREFIX
    koopa::assert_is_dir "$prefix"
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}
