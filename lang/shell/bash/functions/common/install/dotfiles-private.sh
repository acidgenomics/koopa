#!/usr/bin/env bash

# FIXME Rethink this approach...

koopa::install_dotfiles_private() { # {{{1
    # """
    # Install private dot files.
    # @note Updated 2021-06-14.
    # """
    local name_fancy prefix reinstall script
    name='dotfiles-private'
    name_fancy='private dotfiles'
    prefix="$(koopa::dotfiles_private_prefix)"
    reinstall=0
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -d "$prefix" ]] && [[ "$reinstall" -eq 1 ]]
    then
        koopa::alert_note "Removing ${name_fancy} at '${prefix}'."
        koopa::rm "$prefix"
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::add_monorepo_config_link "$name"
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

# FIXME Can we use our standard uninstaller here?
# FIXME Also need to remove the koopa config link...
koopa::uninstall_dotfiles_private() { # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2020-07-05.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_private_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::alert_note "No private dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/uninstall"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}
