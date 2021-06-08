#!/usr/bin/env bash

koopa::install_spacemacs() { # {{{1
    koopa::install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa::spacemacs_prefix)" \
        --version='rolling' \
        --no-shared \
        "$@"
}

koopa:::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-06-07.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local prefix repo
    koopa::assert_has_no_args "$#"
    prefix="${INSTALL_PREFIX:?}"
    repo="https://github.com/syl20bnr/spacemacs.git"
    koopa::git_clone "$repo" "$prefix"
    return 0
}

koopa::uninstall_spacemacs() { # {{{1
    # """
    # Uninstall Spacemacs.
    # @note Updated 2021-06-08.
    # """
    koopa::uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --no-shared \
        --prefix="$(koopa::spacemacs_prefix)" \
        "$@"
}

koopa::update_spacemacs() { # {{{1
    # """
    # Update Spacemacs.
    # @note Updated 2021-06-08.
    #
    # Note that fully non-interactive  '--batch' argument doesn't work with
    # Chemacs2 configuration currently.
    # """
    local emacs name_fancy prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_file "${HOME:?}/.emacs.d/chemacs.el"
    emacs="$(koopa::locate_emacs)"
    name_fancy='Spacemacs'
    koopa::update_start "$name_fancy"
    prefix="$(koopa::spacemacs_prefix)"
    (
        koopa::cd "$prefix"
        koopa::git_pull
    )
    # Can't use '--batch' here with chemacs.
    "$emacs" \
        --no-window-system \
        --with-profile 'spacemacs' \
        --eval='(configuration-layer/update-packages t)'
    koopa::update_success "$name_fancy"
    return 0
}
