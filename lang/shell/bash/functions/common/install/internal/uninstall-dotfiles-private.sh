#!/usr/bin/env bash

# FIXME Call Bash here instead of running script directly.
# FIXME Need to wrap this.
koopa:::uninstall_dotfiles_private() { # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2021-06-14.
    # """
    local name_fancy prefix script
    koopa::assert_has_no_args "$#"
    # FIXME UNINSTALL_PREFIX
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
