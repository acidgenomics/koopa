#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Need to run uninstall script with specific Bash.
koopa:::uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dot files.
    # @note Updated 2021-06-14.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
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
